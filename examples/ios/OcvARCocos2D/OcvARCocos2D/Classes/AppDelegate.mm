/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * AppDelegate implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "AppDelegate.h"
#import "ARScene.h"
#import "ARCtrl.h"
#import "CCNavigationControllerAR.h"

@interface AppDelegate (Private)
/**
 * Will create a proper OpenGL view for property <_glView> with <frame>
 */
- (void)createGLViewWithFrame:(CGRect)frame;
@end

@implementation AppDelegate

/**
 * application start up method. it recreates many things that [CCAppDelegate setupCocos2dWithOptions:]
 * implements but has some modifications to create a custom view hierarchy.
 */
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // create the window
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSLog(@"screen bounds: %dx%d", (int)screenSize.width, (int)screenSize.height);
    if (screenSize.width < screenSize.height) CC_SWAP(screenSize.width, screenSize.height);
    CGRect customBounds = CGRectMake(0, 0, screenSize.width, screenSize.height);
    window_ = [[UIWindow alloc] initWithFrame:customBounds];
    
    // create a custom root view controller
    // this will be the root view controller instead of CCDirector!
    _rootViewCtrl = [[UIViewController alloc] init];
    
    // create the gl view
	[self createGLViewWithFrame:window_.bounds];
    
    // create the director
    CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
    [director setWantsFullScreenLayout:YES];
    
    // set its gl view
    [director setView:_glView];
    
#ifdef DEBUG
    [director setDisplayStats:YES];
#endif
    
    // calculate screen size and content scaling
    NSLog(@"view size in units: %dx%d, scale factor: %f",
          (int)_glView.frame.size.width, (int)_glView.frame.size.height, director.UIScaleFactor);
    
    CGSize size = _glView.frame.size;
    CGSize fixed = {568, 384};
    if (size.width < size.height) CC_SWAP(fixed.width, fixed.height);
    
    CGFloat scaleFactor = size.width / fixed.width;
    
    director.contentScaleFactor = scaleFactor;
    director.UIScaleFactor = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1.0 : 0.5);
    
    // Let CCFileUtils know that "-ipad" textures should be treated as having a contentScale of 2.0.
    [[CCFileUtils sharedFileUtils] setiPadContentScaleFactor: 2.0];
    
    director.designSize = fixed;
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change this setting at any time.
	[CCTexture setDefaultAlphaPixelFormat:CCTexturePixelFormat_RGBA8888];
    
    // Initialise OpenAL
    [OALSimpleAudio sharedInstance];
	
    // create the AR controller which will also create the base view and camera view
    CGFloat arFrameW = size.width;
    CGFloat arFrameH = size.height;
    if (arFrameW < arFrameH) CC_SWAP(arFrameW, arFrameH);
    
    _arCtrl = [[ARCtrl alloc] initWithFrame:CGRectMake(0, 0, arFrameW, arFrameH)
                               orientation:UIInterfaceOrientationLandscapeRight];
    
    [_arCtrl startCam];  // MUST be called before [arCtrl setupProjection]
    
    // the "baseView" contains the camera view
    UIView *baseView = _arCtrl.baseView;
    [baseView addSubview:_glView];    // add the cocos2d opengl on top of the camera view

    // set the base view as view for the root view controller
    [_rootViewCtrl setView:baseView];

    // create the AR start scene
	_arScene = [ARScene sceneWithMarkerScale:[ARCtrl markerScale]];
    [_arScene setTracker:[_arCtrl tracker]];
    [_arCtrl setMainScene:_arScene];
    
    // calculate the AR projection matrix
    [_arCtrl setupProjection];
    
    // gl view frame must fit the video's aspect ratio, so resize it
    [_glView setFrame:[ARCtrl correctedGLViewFrameUnits]];

	// Create a Navigation Controller with the custom root view controller
	CCNavigationControllerAR *navCtrl = [[CCNavigationControllerAR alloc] initWithRootViewController:_rootViewCtrl];
    [navCtrl setNavigationBarHidden:YES];
    [navCtrl setAppDelegateAR:self];
    [navCtrl setScreenOrientationAR:CCScreenOrientationLandscape];
    navController_ = navCtrl;
    
	// for rotation and other messages
	[director setDelegate:navController_];
    
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	   
	// make main window visible
	[window_ makeKeyAndVisible];
    
    
    // fix an error where touches with x > 768 are not recognized. this seems to be
    // a bug related to the window size and orientation. now we set the window
    // height to be equal to the width to recognize all touches. seems weird but works.
    CGRect winRect = window_.bounds;
    if (winRect.size.height < winRect.size.width) {
        winRect.size.height = winRect.size.width;
        [window_ setBounds:winRect];
        [window_ setFrame:winRect];
    }
    
    // somehow, this is necessary here
    [director startAnimation];
    
	return YES;
}



-(CCScene *)startScene
{
    return _arScene;
}

- (void)createGLViewWithFrame:(CGRect)frame {
	_glView = [CCGLView viewWithFrame:frame
                         pixelFormat:kEAGLColorFormatRGBA8
                         depthFormat:GL_DEPTH_COMPONENT24_OES
                  preserveBackbuffer:NO
                          sharegroup:nil
                       multiSampling:NO
                     numberOfSamples:0 ];

    [_glView setOpaque:NO];   // needed for transparent overlay
}

@end
