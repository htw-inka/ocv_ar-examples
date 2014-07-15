//
//  ARCtrl.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 15.07.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import "ARCtrl.h"

#import "Tools.h"

/**
 * Small helper function to convert a fourCC <code> to
 * a character string <fourCC> for printf and the like
 */
void fourCCStringFromCode(int code, char fourCC[5]) {
    for (int i = 0; i < 4; i++) {
        fourCC[3 - i] = code >> (i * 8);
    }
    fourCC[4] = '\0';
}


@implementation ARCtrl

@synthesize camView;
@synthesize baseView;
@synthesize detector;
@synthesize tracker;


#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o {
    self = [super init];
    
    if (self) {
        baseFrame = frame;
        interfOrientation = o;
        director = [CCDirector sharedDirector];
        
        baseView = [[UIView alloc] initWithFrame:baseFrame];
        
        [self initCam];
        [self initAR];
        
        [director setDelegate:self];
        [director setProjection:CCDirectorProjectionCustom];
    }
    
    return self;
}

- (void)dealloc {
    if (detector) delete detector;
    if (tracker) delete tracker;
    
    [self stopCam];
}


#pragma mark public methods

+ (float)markerScale {
    return MARKER_REAL_SIZE_M;
}

- (void)startCam {
    NSLog(@"ARCtrl: starting camera capture");
    [camSession startRunning];
}

- (void)stopCam {
    NSLog(@"ARCtrl: stopping camera capture");
    [camSession stopRunning];
}

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o {
    interfOrientation = o;
    [[(AVCaptureVideoPreviewLayer *)camView.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)o];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // note that this method does *not* run in the main thread!
    
    // convert the incoming YUV camera frame to a grayscale cv mat
    [Tools convertYUVSampleBuffer:sampleBuffer toGrayscaleMat:curFrame];
    
//    if (!detector->isPrepared()) {  // on first frame: prepare for the frames
//        [self prepareForFramesOfSize:CGSizeMake(curFrame.cols, curFrame.rows)
//                         numChannels:curFrame.channels()];
//    }
    
    // tell the tracker to run the detection on the input frame
    tracker->detect(&curFrame);
    
    // get an output frame. may be NULL if no frame processing output is selected
    dispFrame = detector->getOutputFrame();
}

#pragma mark CCDirectorDelegate methods

- (GLKMatrix4)updateProjection {
    director = [CCDirector sharedDirector];
    CGSize viewSize = [director viewSize];
    detector->prepare(1920, 1080, 1);   // to do: get this information from the first camera frame
    float *projMatPtr = detector->getProjMat(viewSize.width, viewSize.height);  // retina scale?
    
    GLKMatrix4 projMat = GLKMatrix4MakeWithArray(projMatPtr);
    
    NSLog(@"ARCtrl: updating projection matrix");
    
    return projMat;
}

#pragma mark private methods

- (void)initCam {
    NSLog(@"ARCtrl: initializing cam");
    
    // init camera view
    camView = [[CamView alloc] initWithFrame:baseFrame];
    [baseView addSubview:camView];
    
    NSError *error = nil;
    
    // set up the camera capture session
    camSession = [[AVCaptureSession alloc] init];
    [camSession setSessionPreset:CAM_SESSION_PRESET];
    [camView setSession:camSession];
    
    // get the camera device
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count <= 0) {
        NSLog(@"ARCtrl: error - no camera found on this device");
        return;
    }
    
	AVCaptureDevice *camDevice = [devices firstObject];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			camDevice = device;
			break;
		}
	}
    
    camDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camDevice error:&error];
    
    if (error || !camDeviceInput) {
        NSLog(@"ARCtrl: error getting camera device: %@", error);
        return;
    }
    
    // add the camera device to the session
    if ([camSession canAddInput:camDeviceInput]) {
        [camSession addInput:camDeviceInput];
        [self interfaceOrientationChanged:interfOrientation];
    }
    
    // create camera output
    vidDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [camSession addOutput:vidDataOutput];
    
    // set output delegate to self
    dispatch_queue_t queue = dispatch_queue_create("vid_output_queue", NULL);
    [vidDataOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    // get best output video format
    NSArray *outputPixelFormats = vidDataOutput.availableVideoCVPixelFormatTypes;
    int bestPixelFormatCode = -1;
    for (NSNumber *format in outputPixelFormats) {
        int code = [format intValue];
        if (bestPixelFormatCode == -1) bestPixelFormatCode = code;  // choose the first as best
        char fourCC[5];
        fourCCStringFromCode(code, fourCC);
        NSLog(@"ARCtrl: available video output format: %s (code %d)", fourCC, code);
    }
    
    // specify output video format
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:bestPixelFormatCode]
                                                               forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [vidDataOutput setVideoSettings:outputSettings];
}

- (void)initAR {
    NSLog(@"ARCtrl: initializing AR system");
    
    assert(!detector && !tracker);
    
    useDistCoeff = USE_DIST_COEFF;
    
    // create the detector
    detector = new ocv_ar::Detect(ocv_ar::IDENT_TYPE_CODE_7X7,  // marker type
                                  MARKER_REAL_SIZE_M,           // real marker size in meters
                                  PROJ_FLIP_MODE);              // projection flip mode
    // create the tracker and pass it a reference to the detector object
    tracker = new ocv_ar::Track(detector);
    
    // load the camera intrinsics
    cv::FileStorage fs;
    const char *path = [[[NSBundle mainBundle] pathForResource:CAM_INTRINSICS_FILE ofType:NULL]
                        cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (!path) {
        NSLog(@"ARCtrl: could not find cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return;
    }
    
    fs.open(path, cv::FileStorage::READ);
    
    if (!fs.isOpened()) {
        NSLog(@"ARCtrl: could not load cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return;
    }
    
    cv::Mat camMat;
    cv::Mat distCoeff;
    
    fs["Camera_Matrix"]  >> camMat;
    
    if (useDistCoeff) {
        fs["Distortion_Coefficients"]  >> distCoeff;
    }
    
    if (camMat.empty()) {
        NSLog(@"ARCtrl: could not load cam instrinsics matrix from file %@", CAM_INTRINSICS_FILE);
        return;
    }
    
    detector->setCamIntrinsics(camMat, distCoeff);
}

@end
