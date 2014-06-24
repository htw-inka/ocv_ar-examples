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
- (void)resizeFrameView:(NSValue *)newFrameRect;

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
        
        detector = new Detect(IDENT_TYPE_CODE_7X7,  // marker type
                              MARKER_REAL_SIZE_M,   // real marker size in meters
                              PROJ_FLIP_MODE);      // projection flip mode
    }
    
    return self;
}

- (void)dealloc {
    [camSession release];
    [camDeviceInput release];
    
    [glView release];
    [CamView release];
    [baseView release];
    
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
    baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.height, screenRect.size.width)];
    
    // create the image view for the camera frames
    camView = [[CamView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.height, screenRect.size.width)];
    
    [baseView addSubview:camView];
    
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
    [glView setNeedsDisplay];
}

- (void)initCam {
    NSLog(@"initializing cam");
    
    NSError *error = nil;
    
    // set up the camera capture session
    camSession = [[AVCaptureSession alloc] init];
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
}

- (BOOL)initDetector {
    FileStorage fs;
    const char *path = [[[NSBundle mainBundle] pathForResource:CAM_INTRINSICS_FILE ofType:NULL]
                        cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (!path) {
        NSLog(@"could not find cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return NO;
    }
    
    fs.open(path, FileStorage::READ);
    
    if (!fs.isOpened()) {
        NSLog(@"could not load cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return NO;
    }
    
    Mat camMat;
    Mat distCoeff;
    
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

- (void)resizeFrameView:(NSValue *)newFrameRect {
    // running this on the main thread is necessary
    // stopping and starting again the camera is also necessary
    
    const CGRect r = [newFrameRect CGRectValue];
    
    [camSession stopRunning];
    [camView setFrame:r];
    [camSession startRunning];
    
    // also calculate a new GL projection matrix and resize the gl view
    float *projMatPtr = detector->getProjMat(r.size.width, r.size.height);
    [glView setMarkerProjMat:projMatPtr];
    [glView setFrame:r];
    [glView resizeView:r.size];
    
    NSLog(@"new view size %dx%d, pos %d,%d",
          (int)camView.frame.size.width, (int)camView.frame.size.height,
          (int)camView.frame.origin.x, (int)camView.frame.origin.y);
}

- (void)procOutputSelectBtnAction:(UIButton *)sender {
    NSLog(@"proc output selection button pressed: %@ (proc type %ld)",
          [sender titleForState:UIControlStateNormal], (long)sender.tag);
    
    [glView setShowMarkers:(sender.tag < 0)];   // only show markers in "normal" display mode
    
    detector->setFrameOutputLevel((ocv_ar::FrameProcLevel)sender.tag);
}

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o {
    [[(AVCaptureVideoPreviewLayer *)camView.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)o];
}

@end
