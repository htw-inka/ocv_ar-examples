/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Augmented Reality controller implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "ARCtrl.h"

#import "Tools.h"
#import "CCNavigationControllerAR.h"

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
static CGRect _correctedGLViewFramePx;
static CGRect _correctedGLViewFrameUnits;

@synthesize baseView = _baseView;
@synthesize detector = _detector;
@synthesize tracker = _tracker;
@synthesize mainScene = _mainScene;

#pragma mark static methods

+ (const GLKMatrix4 *)arProjectionMatrix {
    return _arProjMat;
}

+ (CGRect)correctedGLViewFramePx {
    return _correctedGLViewFramePx;
}

+ (CGRect)correctedGLViewFrameUnits {
    return _correctedGLViewFrameUnits;
}

#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o {
    self = [super init];
    
    if (self) {
        // find out the ipad model
        NSString *machineInfoShort = [Tools deviceModelShort];
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
        
        // set camera intrinsics file from model name
        _camIntrinsicsFile = [NSString stringWithFormat:@"ipad%d-front.xml", machineModelVersion];

        // set defaults
        _interfOrientation = o;
        _baseFrame = frame;
        _director = [CCDirector sharedDirector];
        _arSysReady = NO;
        
        // run initializations
        [self initBase];
        [self initCam];
        [self initAR];
    }
    
    return self;
}

- (void)dealloc {
    [self stopCam];
    
    if (_detector) delete _detector;
    if (_tracker) delete _tracker;
    
    if (_arProjMat) delete _arProjMat;
}


#pragma mark public methods

- (void)setupProjection {
    // set projection to "custom projection" and set the CCDirectorDelegate to self
    // this will cause the CCDirector to call the "updateProjection" on this object
    [_director setDelegate:self];
    [_director setProjection:CCDirectorProjectionCustom];
}

+ (float)markerScale {
    return MARKER_REAL_SIZE_M;
}

- (void)startCam {
    NSLog(@"ARCtrl: starting camera capture");
    [_camSession startRunning];
}

- (void)stopCam {
    NSLog(@"ARCtrl: stopping camera capture");
    [_camSession stopRunning];
}

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o {
    _interfOrientation = o;
    [[(AVCaptureVideoPreviewLayer *)_camView.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)o];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // note that this method does *not* run in the main thread!
    
    // convert the incoming YUV camera frame to a grayscale cv mat
    [Tools convertYUVSampleBuffer:sampleBuffer toGrayscaleMat:_curFrame];
    
    if (!_detector->isPrepared()) {  // on first frame: prepare for the frames
        [self prepareForFramesOfSize:CGSizeMake(_curFrame.cols, _curFrame.rows)
                         numChannels:_curFrame.channels()];
    }
    
    // tell the tracker to run the detection on the input frame
    _tracker->detect(&_curFrame);
    
    // get an output frame. may be NULL if no frame processing output is selected
    _dispFrame = _detector->getOutputFrame();
    
    // update the views on the main thread
    if (_dispFrame) {
        [self performSelectorOnMainThread:@selector(updateViews)
                               withObject:nil
                            waitUntilDone:NO];
    }
}

#pragma mark CCDirectorDelegate methods

- (GLKMatrix4)updateProjection {
    // get the view size in pixels
    CGSize viewSize = [[CCDirector sharedDirector] viewSizeInPixels];
    
    if (viewSize.width < viewSize.height) {
        CC_SWAP(viewSize.width, viewSize.height);
    }

    NSLog(@"ARCtrl: updating projection matrix for view size %dx%d px", (int)viewSize.width, (int)viewSize.height);
    
    while (!_arSysReady) { } // wait until prepareForFramesOfSize:numChannels: is called!
    
    // update the gl view frame to reflect the video aspect ratio
    CGFloat glFrameW = viewSize.width;
    CGFloat glFrameH = viewSize.width / _vidFrameAspRatio;
    CGFloat glFrameOffset = (viewSize.height - glFrameH) / 2.0f;
    _correctedGLViewFramePx = CGRectMake(0.0f, glFrameOffset, glFrameW, glFrameH);
    
    NSLog(@"ARCtrl: updating gl view frame to %dx%d px @ %d, %d px",
          (int)_correctedGLViewFramePx.size.width, (int)_correctedGLViewFramePx.size.height,
          (int)_correctedGLViewFramePx.origin.x, (int)_correctedGLViewFramePx.origin.y);
    
    float sf = 1.0f / [CCNavigationControllerAR uiScreenScale];
    
    _correctedGLViewFrameUnits = CGRectMake(_correctedGLViewFramePx.origin.x * sf,
                                            _correctedGLViewFramePx.origin.y * sf,
                                            _correctedGLViewFramePx.size.width * sf,
                                            _correctedGLViewFramePx.size.height * sf);
    
    // also resize the processing frame view
    [_procFrameView setFrame:_correctedGLViewFrameUnits];
    
    // get the AR projection matrix
    float *projMatPtr = _detector->getProjMat(glFrameW, glFrameH);
    GLKMatrix4 projMat = GLKMatrix4MakeWithArray(projMatPtr);
    
    if (!_arProjMat) {
        _arProjMat = new GLKMatrix4;
    }
    
    memcpy(_arProjMat, &projMat, sizeof(GLKMatrix4));
    
    return projMat;
}

#pragma mark private methods

- (void)initBase {
    _baseView = [[UIView alloc] initWithFrame:_baseFrame];
    
    // create view for processed frames
    _procFrameView = [[UIImageView alloc] initWithFrame:_baseFrame];
    [_procFrameView setHidden:YES];  // initially hidden
    [_baseView addSubview:_procFrameView];
    
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
        
        [_baseView addSubview:procOutputSelectBtn];
    }
}

- (void)initCam {
    NSLog(@"ARCtrl: initializing cam");
    
    // init camera view
    _camView = [[CamView alloc] initWithFrame:_baseFrame];
    [_baseView insertSubview:_camView belowSubview:_procFrameView];
    
    NSError *error = nil;
    
    // set up the camera capture session
    _camSession = [[AVCaptureSession alloc] init];
    [_camSession setSessionPreset:CAM_SESSION_PRESET];
    [_camView setSession:_camSession];
    
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
    
    _camDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camDevice error:&error];
    
    if (error || !_camDeviceInput) {
        NSLog(@"ARCtrl: error getting camera device: %@", error);
        return;
    }
    
    // add the camera device to the session
    if ([_camSession canAddInput:_camDeviceInput]) {
        [_camSession addInput:_camDeviceInput];
        [self interfaceOrientationChanged:_interfOrientation];
    }
    
    // create camera output
    _vidDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_camSession addOutput:_vidDataOutput];
    
    // set output delegate to self
    dispatch_queue_t queue = dispatch_queue_create("vid_output_queue", NULL);
    [_vidDataOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    // get best output video format
    NSArray *outputPixelFormats = _vidDataOutput.availableVideoCVPixelFormatTypes;
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
    [_vidDataOutput setVideoSettings:outputSettings];
}

- (void)initAR {
    NSLog(@"ARCtrl: initializing AR system, using cam intrinsics from file %@", _camIntrinsicsFile);
    
    assert(!_detector && !_tracker);
    
    _useDistCoeff = USE_DIST_COEFF;
    
    // create the detector
    _detector = new ocv_ar::Detect(ocv_ar::IDENT_TYPE_CODE_7X7,  // marker type
                                   MARKER_REAL_SIZE_M,           // real marker size in meters
                                   PROJ_FLIP_MODE);              // projection flip mode
    // create the tracker and pass it a reference to the detector object
    _tracker = new ocv_ar::Track(_detector);
    
    // load the camera intrinsics
    cv::FileStorage fs;
    const char *path = [[[NSBundle mainBundle] pathForResource:_camIntrinsicsFile ofType:NULL]
                        cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (!path) {
        NSLog(@"ARCtrl: could not find cam intrinsics file %@", _camIntrinsicsFile);
        return;
    }
    
    fs.open(path, cv::FileStorage::READ);
    
    if (!fs.isOpened()) {
        NSLog(@"ARCtrl: could not load cam intrinsics file %@", _camIntrinsicsFile);
        return;
    }
    
    cv::Mat camMat;
    cv::Mat distCoeff;
    
    fs["Camera_Matrix"]  >> camMat;
    
    if (_useDistCoeff) {
        fs["Distortion_Coefficients"]  >> distCoeff;
    }
    
    if (camMat.empty()) {
        NSLog(@"ARCtrl: could not load cam instrinsics matrix from file %@", _camIntrinsicsFile);
        return;
    }
    
    _detector->setCamIntrinsics(camMat, distCoeff);
}

-(void)prepareForFramesOfSize:(CGSize)frameSize numChannels:(int)channels {
    _detector->prepare(frameSize.width, frameSize.height, channels);
    _vidFrameAspRatio = frameSize.width / frameSize.height;
    
    NSLog(@"ARCtrl: prepared for frames of size %dx%d (asp. ratio %f)",
          (int)frameSize.width, (int)frameSize.height, _vidFrameAspRatio);
    
    _arSysReady = YES;
}

- (void)updateViews {
    // this method is only to display the intermediate frame processing
    // output of the detector.
    // (it is slow but it's only for debugging)
    
    // when we have a frame to display in "_procFrameView" ...
    // ... convert it to an UIImage
    UIImage *dispUIImage = [Tools imageFromCvMat:_dispFrame];
    
    // and display it with the UIImageView "_procFrameView"
    [_procFrameView setImage:dispUIImage];
    [_procFrameView setNeedsDisplay];
}

- (void)procOutputSelectBtnAction:(UIButton *)sender {
    NSLog(@"proc output selection button pressed: %@ (proc type %ld)",
          [sender titleForState:UIControlStateNormal], (long)sender.tag);
    
    BOOL normalDispMode = (sender.tag < 0);
    [_mainScene setVisible:normalDispMode];    // only show markers in "normal" display mode
    [_camView setHidden:!normalDispMode];      // only show original camera frames in "normal" display mode
    [_procFrameView setHidden:normalDispMode]; // only show processed frames for other than "normal" display mode
    
    _detector->setFrameOutputLevel((ocv_ar::FrameProcLevel)sender.tag);
}

@end
