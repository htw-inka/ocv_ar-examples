//
//  AppDelegate.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 08.07.14.
//  Copyright INKA Research Group 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "ARScene.h"
#import "ARCtrl.h"
#import "CCNavigationControllerAR.h"

@interface AppDelegate (Private)
- (void)createGLViewWithFrame:(CGRect)frame;
@end

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Custom AppDelegate launch method
    // We need full power over how the view hiearchy is created, that's why this method does not use cocos2d's
    // default setup function
    
    // create the window
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    NSLog(@"screen bounds: %dx%d", (int)screenSize.width, (int)screenSize.height);
    if (screenSize.width < screenSize.height) CC_SWAP(screenSize.width, screenSize.height);
    CGRect customBounds = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.window = [[UIWindow alloc] initWithFrame:customBounds];
    
    // create a custom root view controller
    // this will be the root view controller instead of CCDirector!
    rootViewCtrl = [[RootViewCtrl alloc] init];
    
    // create the gl view
	[self createGLViewWithFrame:self.window.bounds];
    
    // create the director
    CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
    [director setWantsFullScreenLayout:YES];
    
    // set its gl view
    [director setView:glView];
    
#ifdef DEBUG
    [director setDisplayStats:YES];
#endif
    
    // calculate screen size and content scaling
    NSLog(@"view size in units: %dx%d, scale factor: %f",
          (int)glView.frame.size.width, (int)glView.frame.size.height,  director.UIScaleFactor);
    
    CGSize size = glView.frame.size;
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
    
    arCtrl = [[ARCtrl alloc] initWithFrame:CGRectMake(0, 0, arFrameW, arFrameH)
                               orientation:UIInterfaceOrientationLandscapeRight];
    
    [arCtrl startCam];  // MUST be called before [arCtrl setupProjection]
    
    // the "baseView" contains the camera view
    UIView *baseView = arCtrl.baseView;
    [baseView addSubview:glView];    // add the cocos2d opengl on top of the camera view

    [rootViewCtrl setView:baseView];

    // create the AR start scene
	arScene = [ARScene sceneWithMarkerScale:[ARCtrl markerScale]];
    [arScene setTracker:[arCtrl tracker]];
    [arCtrl setMainScene:arScene];
    
    // calculate the AR projection matrix
    [arCtrl setupProjection];
    
    // gl view frame must fit the video's aspect ratio, so resize it
    [glView setFrame:[ARCtrl correctedGLViewFrameUnits]];

	// Create a Navigation Controller with the custom root view controller
	CCNavigationControllerAR *navCtrl = [[CCNavigationControllerAR alloc] initWithRootViewController:rootViewCtrl];
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
    
    // somehow, this is necessary here
    [director startAnimation];
    
    CGRect glViewFrame = glView.frame;
    
	return YES;
}



-(CCScene *)startScene
{
    return arScene;
}

- (void)createGLViewWithFrame:(CGRect)frame {
	glView = [CCGLView viewWithFrame:frame
                         pixelFormat:kEAGLColorFormatRGBA8
                         depthFormat:GL_DEPTH_COMPONENT24_OES
                  preserveBackbuffer:NO
                          sharegroup:nil
                       multiSampling:NO
                     numberOfSamples:0 ];

    [glView setOpaque:NO];   // needed for transparent overlay
}

@end
