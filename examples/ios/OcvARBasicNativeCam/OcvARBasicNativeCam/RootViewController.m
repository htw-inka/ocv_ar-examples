/**
 * OcvARBasicNativeCam - Basic ocv_ar example for iOS with native camera usage
 *
 * Main view controller - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import "RootViewController.h"
#import "helper/Tools.h"

void fourCCStringFromCode(int code, char fourCC[5]) {
    for (int i = 0; i < 4; i++) {
        fourCC[3 - i] = code >> (i * 8);
    }
    fourCC[4] = '\0';
}

@interface RootViewController(Private)
/**
 * initialize camera
 */
- (void)initCam;

/**
 * initialize ocv_ar marker detector
 */
- (BOOL)initDetector;

/**
 * resize the frame view to CGRect in <newFrameRect>
 */
//- (void)resizeFrameView:(NSValue *)newFrameRect;

/**
 * Called on the first input frame and prepares everything for the specified
 * frame size and number of color channels
 */
- (void)prepareForFramesOfSize:(CGSize)size numChannels:(int)chan;

/**
 * resize the proc frame view to CGRect in <newFrameRect>
 */
- (void)resizeProcFrameView:(NSValue *)newFrameRect;

/**
 * Notify the video session about the interface orientation change
 */
- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o;

/**
 * handler that is called when a output selection button is pressed
 */
- (void)procOutputSelectBtnAction:(UIButton *)sender;

/**
 * force to redraw views
 */
- (void)updateViews;
@end


@implementation RootViewController

#pragma mark init/dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        useDistCoeff = USE_DIST_COEFF;
        
        detector = new ocv_ar::Detect(ocv_ar::IDENT_TYPE_CODE_7X7,  // marker type
                                      MARKER_REAL_SIZE_M,   // real marker size in meters
                                      PROJ_FLIP_MODE);      // projection flip mode
    }
    
    return self;
}

- (void)dealloc {
    // release camera stuff
    [vidDataOutput release];
    [camDeviceInput release];
    [camSession release];
    
    // release views
    [glView release];
    [camView release];
    [procFrameView release];
    [baseView release];
    
    // delete marker detection
    if (detector) delete detector;
    
    [super dealloc];
}

#pragma mark parent methods

- (void)didReceiveMemoryWarning {
    NSLog(@"memory warning!!!");
    
    [super didReceiveMemoryWarning];
}

- (void)loadView {
    const CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSLog(@"loading view of size %dx%d", (int)screenRect.size.width, (int)screenRect.size.height);
    
    // create an empty base view
    CGRect baseFrame = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
    baseView = [[UIView alloc] initWithFrame:baseFrame];
    
    // create the image view for the camera frames
    camView = [[CamView alloc] initWithFrame:baseFrame];
    
    [baseView addSubview:camView];
    
    // create view for processed frames
    procFrameView = [[UIImageView alloc] initWithFrame:baseFrame];
    [procFrameView setHidden:YES];
    [baseView addSubview:procFrameView];
    
    // create the GL view
    glView = [[GLView alloc] initWithFrame:baseView.frame];
    [baseView addSubview:glView];
    
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
    
    // finally set the base view as view for this controller
    [self setView:baseView];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear - start camera session");
    
    [camSession startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"view did disappear - stop camera session");
    
    [camSession stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init detector
    if ([self initDetector]) {
        NSLog(@"cam intrinsics loaded from file %@", CAM_INTRINSICS_FILE);
    } else {
        NSLog(@"detector initialization failure");
    }
    
    // set the marker scale for the GL view
    [glView setMarkerScale:detector->getMarkerScale()];
    
    // set up camera
    [self initCam];
//    [cam start];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)o duration:(NSTimeInterval)duration {
    [self interfaceOrientationChanged:o];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    [Tools convertYUVSampleBuffer:sampleBuffer toMat:curFrame];
    
    if (!detector->isPrepared()) {  // on first frame: prepare the detector
        [self prepareForFramesOfSize:CGSizeMake(curFrame.cols, curFrame.rows) numChannels:curFrame.channels()];
        
//        // also calculate a new GL projection matrix and resize the gl view
//        float *projMatPtr = detector->getProjMat(camView.frame.size.width, camView.frame.size.height);
//        [glView setMarkerProjMat:projMatPtr];
//        [glView setFrame:camView.frame];
//        [glView resizeView:camView.frame.size];
    }
    
    detector->setInputFrame(&curFrame);
    
    detector->processFrame();
    
    dispFrame = detector->getOutputFrame();
    
//    dispFrame = &curFrame;
    
//    [glView setMarkers:detector->getMarkers()];
    
    [self performSelectorOnMainThread:@selector(updateViews)
                           withObject:nil
                        waitUntilDone:NO];
}

//#pragma mark CvVideoCameraDelegate methods
//
//- (void)processImage:(Mat &)image {
//    if (!detector->isPrepared()) {  // on first frame: prepare the detector
//        detector->prepare(image.cols, image.rows, image.channels());
//        
//        float frameAspectRatio = (float)image.cols / (float)image.rows;
//        NSLog(@"camera frames are of size %dx%d (aspect %f)", image.cols, image.rows, frameAspectRatio);
//        
//        float viewW = camView.frame.size.width;  // this is for landscape view
//        float viewH = camView.frame.size.height;   // this is for landscape view
//        NSLog(@"view is of size %dx%d (aspect %f)", (int)viewW, (int)viewH, viewW / viewH);
//        if (frameAspectRatio != viewW / viewH) { // aspect ratio does not fit
//            float newViewH = viewW / frameAspectRatio;   // calc new height
//            float viewYOff = (viewH - newViewH) / 2;
//            NSLog(@"changed view size to %dx%d", (int)viewW, (int)newViewH);
//            CGRect newFrameViewRect = CGRectMake(0, viewYOff, viewW, newViewH);
//            
//            // processImage is not running on the main thread, therefore
//            // calling "setFrame" would have no effect!
//            [self performSelectorOnMainThread:@selector(resizeFrameView:)
//                                   withObject:[NSValue valueWithCGRect:newFrameViewRect]
//                                waitUntilDone:NO];
//        }
//    }
//    
//    // set the grabbed frame as input
//    detector->setInputFrame(&image);
//    
//    // process the frame
//    detector->processFrame();
//    
//    // "outFrame" is only set when a processing level for output is selected
//    Mat *outFrame = detector->getOutputFrame();
//    
//    if (outFrame) { // display this frame instead of the original camera frame
//        outFrame->copyTo(image);
//    }
//    
//    // update gl view
//    [glView setMarkers:detector->getMarkers()];
//    
//    [self performSelectorOnMainThread:@selector(updateViews)
//                           withObject:nil
//                        waitUntilDone:NO];
//}

#pragma mark private methods

- (void)updateViews {
    if (dispFrame) {
        UIImage *dispUIImage = [Tools imageFromCvMat:dispFrame];
        [procFrameView setImage:dispUIImage];
        [procFrameView setNeedsDisplay];
//        CGImageRef dispCGImg = [Tools CGImageFromCvMat:*dispFrame];
//        [camView.layer setFrame:CGRectMake(0, 0, dispFrame->cols, dispFrame->rows)];
//        [camView.layer setContents:(id)dispCGImg];
//        [camView setNeedsDisplay];
//        CGImageRelease(dispCGImg);
    }
    
    [glView setNeedsDisplay];
}

- (void)initCam {
    NSLog(@"initializing cam");
    
    NSError *error = nil;
    
    // set up the camera capture session
    camSession = [[AVCaptureSession alloc] init];
    [camSession setSessionPreset:CAM_SESSION_PRESET];
    [camView setSession:camSession];
    
    // get the camera device
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    assert(devices.count > 0);
    
	AVCaptureDevice *camDevice = [devices firstObject];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			camDevice = device;
			break;
		}
	}
    
    camDeviceInput = [[AVCaptureDeviceInput deviceInputWithDevice:camDevice error:&error] retain];
    
    if (error) {
        NSLog(@"error getting camera device: %@", error);
        return;
    }
    
    assert(camDeviceInput);
    
    // add the camera device to the session
    if ([camSession canAddInput:camDeviceInput]) {
        [camSession addInput:camDeviceInput];
        [self interfaceOrientationChanged:self.interfaceOrientation];
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
        NSLog(@"available video output format: %s (code %d)", fourCC, code);
    }

    // specify output video format
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:bestPixelFormatCode]
                                                               forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [vidDataOutput setVideoSettings:outputSettings];
    
//    // cap to 15 fps
//    [vidDataOutput setMinFrameDuration:CMTimeMake(1, 15)];
}

- (BOOL)initDetector {
    cv::FileStorage fs;
    const char *path = [[[NSBundle mainBundle] pathForResource:CAM_INTRINSICS_FILE ofType:NULL]
                        cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (!path) {
        NSLog(@"could not find cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return NO;
    }
    
    fs.open(path, cv::FileStorage::READ);
    
    if (!fs.isOpened()) {
        NSLog(@"could not load cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return NO;
    }
    
    cv::Mat camMat;
    cv::Mat distCoeff;
    
    fs["Camera_Matrix"]  >> camMat;
    
    if (useDistCoeff) {
        fs["Distortion_Coefficients"]  >> distCoeff;
    }
    
    if (camMat.empty()) {
        NSLog(@"could not load cam instrinsics matrix from file %@", CAM_INTRINSICS_FILE);
        
        return NO;
    }
    
    detector->setCamIntrinsics(camMat, distCoeff);
    
    return YES;
}

- (void)prepareForFramesOfSize:(CGSize)size numChannels:(int)chan {
    detector->prepare(size.width, size.height, chan);
    
    float frameAspectRatio = size.width / size.height;
    NSLog(@"camera frames are of size %dx%d (aspect %f)", (int)size.width, (int)size.height, frameAspectRatio);

    float newViewH = procFrameView.frame.size.width / frameAspectRatio;   // calc new height
    float viewYOff = (procFrameView.frame.size.height - newViewH) / 2;
    
    CGRect newFrameViewRect = CGRectMake(0, viewYOff, procFrameView.frame.size.width, newViewH);
    [self performSelectorOnMainThread:@selector(resizeProcFrameView:)
                           withObject:[NSValue valueWithCGRect:newFrameViewRect]
                        waitUntilDone:NO];
}

- (void)resizeProcFrameView:(NSValue *)newFrameRect {
    [procFrameView setFrame:[newFrameRect CGRectValue]];
}

//- (void)resizeFrameView:(NSValue *)newFrameRect {
//    // running this on the main thread is necessary
//    // stopping and starting again the camera is also necessary
//    
//    const CGRect r = [newFrameRect CGRectValue];
//    
//    [camSession stopRunning];
//    [camView setFrame:r];
//    [camSession startRunning];
//    
//    // also calculate a new GL projection matrix and resize the gl view
//    float *projMatPtr = detector->getProjMat(r.size.width, r.size.height);
//    [glView setMarkerProjMat:projMatPtr];
//    [glView setFrame:r];
//    [glView resizeView:r.size];
//    
//    NSLog(@"new view size %dx%d, pos %d,%d",
//          (int)camView.frame.size.width, (int)camView.frame.size.height,
//          (int)camView.frame.origin.x, (int)camView.frame.origin.y);
//}

- (void)procOutputSelectBtnAction:(UIButton *)sender {
    NSLog(@"proc output selection button pressed: %@ (proc type %ld)",
          [sender titleForState:UIControlStateNormal], (long)sender.tag);
    
    BOOL normalDispMode = (sender.tag < 0);
    [glView setShowMarkers:normalDispMode];   // only show markers in "normal" display mode
    [camView setHidden:!normalDispMode];      // only show original camera frames in "normal" display mode
    [procFrameView setHidden:normalDispMode]; // only show processed frames for other than "normal" display mode
    
    detector->setFrameOutputLevel((ocv_ar::FrameProcLevel)sender.tag);
}

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o {
    [[(AVCaptureVideoPreviewLayer *)camView.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)o];
}

@end
