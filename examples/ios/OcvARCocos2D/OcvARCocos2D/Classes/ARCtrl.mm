//
//  ARCtrl.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 15.07.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import "ARCtrl.h"

#import <sys/utsname.h>
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


@interface ARCtrl (Private)

/**
 * Init base view
 */
- (void)initBase;

/**
 * Init camera and camera preview
 */
- (void)initCam;

/**
 * Init AR system
 */
- (void)initAR;

/**
 * Called on the first input frame and prepares everything for the specified
 * frame size and number of color channels
 */
- (void)prepareForFramesOfSize:(CGSize)frameSize numChannels:(int)channels;

/**
 * force to redraw views. this method is only to display the intermediate
 * frame processing output for debugging
 */
- (void)updateViews;

/**
 * handler that is called when a output selection button is pressed
 */
- (void)procOutputSelectBtnAction:(UIButton *)sender;

@end


@implementation ARCtrl

static GLKMatrix4 *_arProjMat = NULL;
static CGRect _correctedGLViewFrame;

@synthesize baseView;
@synthesize detector;
@synthesize tracker;
@synthesize mainScene;

#pragma mark static methods

+ (const GLKMatrix4 *)arProjectionMatrix {
    return _arProjMat;
}

+ (CGRect)correctedGLViewFrame {
    return _correctedGLViewFrame;
}

#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o {
    self = [super init];
    
    if (self) {
        // find out the ipad model
        
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *machineInfo = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
        NSString *machineInfoShort = [[machineInfo substringToIndex:5] lowercaseString];
        
        NSLog(@"ARCtrl: device model (short) is %@", machineInfoShort);
        
        int machineModelVersion = 0;
        if ([machineInfoShort isEqualToString:@"ipad2"]) {
            machineModelVersion = 2;
        } else if ([machineInfoShort isEqualToString:@"ipad3"]) {
            machineModelVersion = 3;
        } else {
            NSLog(@"RootViewController: no camera intrinsics available for this model!");
            machineModelVersion = 2;    // default. might not work!
        }
        
        camIntrinsicsFile = [NSString stringWithFormat:@"ipad%d-front.xml", machineModelVersion];

        
        interfOrientation = o;
        baseFrame = frame;
        director = [CCDirector sharedDirector];
        arSysReady = NO;
        
        [self initBase];
        [self initCam];
        [self initAR];
    }
    
    return self;
}

- (void)dealloc {
    if (detector) delete detector;
    if (tracker) delete tracker;
    
    if (_arProjMat) delete _arProjMat;
    
    [self stopCam];
}


#pragma mark public methods

- (void)setupProjection {
    // set projection to "custom projection" and set the CCDirectorDelegate to self
    // this will cause the CCDirector to call the "updateProjection" on this object
    [director setDelegate:self];
    [director setProjection:CCDirectorProjectionCustom];
}

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
    
    if (!detector->isPrepared()) {  // on first frame: prepare for the frames
        [self prepareForFramesOfSize:CGSizeMake(curFrame.cols, curFrame.rows)
                         numChannels:curFrame.channels()];
    }
    
    // tell the tracker to run the detection on the input frame
    tracker->detect(&curFrame);
    
    // get an output frame. may be NULL if no frame processing output is selected
    dispFrame = detector->getOutputFrame();
    
    // update the views on the main thread
    if (dispFrame) {
        [self performSelectorOnMainThread:@selector(updateViews)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

#pragma mark CCDirectorDelegate methods

- (GLKMatrix4)updateProjection {
    CGSize viewSize = [[CCDirector sharedDirector] viewSizeInPixels];
    
    if (viewSize.width < viewSize.height) {
        CC_SWAP(viewSize.width, viewSize.height);
    }

    NSLog(@"ARCtrl: updating projection matrix for view size %dx%d", (int)viewSize.width, (int)viewSize.height);
    
    while (!arSysReady) { } // wait until prepareForFramesOfSize:numChannels: is called!
    
    // update the gl view frame to reflect the video aspect ratio
    CGFloat glFrameW = viewSize.width;
    CGFloat glFrameH = viewSize.width / vidFrameAspRatio;
    CGFloat glFrameOffset = (viewSize.height - glFrameH) / 2.0f;
    _correctedGLViewFrame = CGRectMake(0.0f, glFrameOffset, glFrameW, glFrameH);
    
    NSLog(@"ARCtrl: updating gl view frame to %dx%d @ %d, %d",
          (int)_correctedGLViewFrame.size.width, (int)_correctedGLViewFrame.size.height,
          (int)_correctedGLViewFrame.origin.x, (int)_correctedGLViewFrame.origin.y);
    
    // also resize the processing frame view
    [procFrameView setFrame:_correctedGLViewFrame];
    
    // get the AR projection matrix
    float *projMatPtr = detector->getProjMat(glFrameW, glFrameH);
    GLKMatrix4 projMat = GLKMatrix4MakeWithArray(projMatPtr);
    
    if (!_arProjMat) {
        _arProjMat = new GLKMatrix4;
    }
    
    memcpy(_arProjMat, &projMat, sizeof(GLKMatrix4));
    
    return projMat;
}

#pragma mark private methods

- (void)initBase {
    baseView = [[UIView alloc] initWithFrame:baseFrame];
    
    // create view for processed frames
    procFrameView = [[UIImageView alloc] initWithFrame:baseFrame];
    [procFrameView setHidden:YES];  // initially hidden
    [baseView addSubview:procFrameView];
    
    // set a list of buttons for processing output display
    NSArray *btnTitles = [NSArray arrayWithObjects:
                          @"Normal",
                          @"Preproc",
                          @"Thresh",
                          @"Contours",
                          @"Candidates",
                          @"Detected",
                          nil];
    for (int btnIdx = 0; btnIdx < btnTitles.count; btnIdx++) {
        UIButton *procOutputSelectBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [procOutputSelectBtn setTag:btnIdx - 1];
        [procOutputSelectBtn setTitle:[btnTitles objectAtIndex:btnIdx]
                             forState:UIControlStateNormal];
        int btnW = 120;
        [procOutputSelectBtn setFrame:CGRectMake(10 + (btnW + 20) * btnIdx, 10, btnW, 35)];
        [procOutputSelectBtn setOpaque:YES];
        [procOutputSelectBtn addTarget:self
                                action:@selector(procOutputSelectBtnAction:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        [baseView addSubview:procOutputSelectBtn];
    }
}

- (void)initCam {
    NSLog(@"ARCtrl: initializing cam");
    
    // init camera view
    camView = [[CamView alloc] initWithFrame:baseFrame];
    [baseView insertSubview:camView belowSubview:procFrameView];
    
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
    NSLog(@"ARCtrl: initializing AR system, using cam intrinsics from file %@", camIntrinsicsFile);
    
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
    const char *path = [[[NSBundle mainBundle] pathForResource:camIntrinsicsFile ofType:NULL]
                        cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (!path) {
        NSLog(@"ARCtrl: could not find cam intrinsics file %@", camIntrinsicsFile);
        return;
    }
    
    fs.open(path, cv::FileStorage::READ);
    
    if (!fs.isOpened()) {
        NSLog(@"ARCtrl: could not load cam intrinsics file %@", camIntrinsicsFile);
        return;
    }
    
    cv::Mat camMat;
    cv::Mat distCoeff;
    
    fs["Camera_Matrix"]  >> camMat;
    
    if (useDistCoeff) {
        fs["Distortion_Coefficients"]  >> distCoeff;
    }
    
    if (camMat.empty()) {
        NSLog(@"ARCtrl: could not load cam instrinsics matrix from file %@", camIntrinsicsFile);
        return;
    }
    
    detector->setCamIntrinsics(camMat, distCoeff);
}

-(void)prepareForFramesOfSize:(CGSize)frameSize numChannels:(int)channels {
    detector->prepare(frameSize.width, frameSize.height, channels);
    vidFrameAspRatio = frameSize.width / frameSize.height;
    
    NSLog(@"ARCtrl: prepared for frames of size %dx%d (asp. ratio %f)",
          (int)frameSize.width, (int)frameSize.height, vidFrameAspRatio);
    
    arSysReady = YES;
}

- (void)updateViews {
    // this method is only to display the intermediate frame processing
    // output of the detector.
    // (it is slow but it's only for debugging)
    
    // when we have a frame to display in "procFrameView" ...
    // ... convert it to an UIImage
    UIImage *dispUIImage = [Tools imageFromCvMat:dispFrame];
    
    // and display it with the UIImageView "procFrameView"
    [procFrameView setImage:dispUIImage];
    [procFrameView setNeedsDisplay];
}

- (void)procOutputSelectBtnAction:(UIButton *)sender {
    NSLog(@"proc output selection button pressed: %@ (proc type %ld)",
          [sender titleForState:UIControlStateNormal], (long)sender.tag);
    
    BOOL normalDispMode = (sender.tag < 0);
    [mainScene setVisible:normalDispMode];    // only show markers in "normal" display mode
    [camView setHidden:!normalDispMode];      // only show original camera frames in "normal" display mode
    [procFrameView setHidden:normalDispMode]; // only show processed frames for other than "normal" display mode
    
    detector->setFrameOutputLevel((ocv_ar::FrameProcLevel)sender.tag);
}

@end
