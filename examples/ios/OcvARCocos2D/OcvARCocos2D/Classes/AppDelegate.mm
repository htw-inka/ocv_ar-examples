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
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	[self createGLViewWithFrame:self.window.bounds];
    
    CCDirectorIOS *director = (CCDirectorIOS*) [CCDirector sharedDirector];
    [director setWantsFullScreenLayout:YES];
    
#ifdef DEBUG
    [director setDisplayStats:YES];
#endif
    
    [director setView:glView];
    
    CGSize size = [CCDirector sharedDirector].viewSizeInPixels;
    CGSize fixed = {384, 568};
    
    CGFloat scaleFactor = size.width / fixed.width;
    
    NSLog(@"size %dx%d, scale factor %f", (int)size.width, (int)size.height, scaleFactor);
    
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
	
	// Create a Navigation Controller with the Director
	CCNavigationControllerAR *navCtrl = [[CCNavigationControllerAR alloc] initWithRootViewController:director];
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
    
    [director.view setOpaque:NO];   // needed for transparent overlay
    
    // "viewSize" returns the wrong px size (512x384), so we use viewSizeInPixels
    NSLog(@"view size in px: %dx%d, scale factor: %f",
          (int)director.viewSizeInPixels.width, (int)director.viewSizeInPixels.height,  director.UIScaleFactor);
    int viewWUnits = director.viewSizeInPixels.width * director.UIScaleFactor;
    int viewHUnits = director.viewSizeInPixels.height * director.UIScaleFactor;
    arCtrl = [[ARCtrl alloc] initWithFrame:CGRectMake(0, 0, viewWUnits, viewHUnits)
                               orientation:window_.rootViewController.interfaceOrientation];
    
    [arCtrl startCam];  // must be called before the subsequent commands
    
    // the "baseView" contains the camera view
    UIView *baseView = arCtrl.baseView;
    [baseView addSubview:director.view];    // add the cocos2d opengl on top of the camera view
    // replace cocos2d opengl view by "baseView" with camera view and opengl overlay
    [self.window.rootViewController setView:baseView];
    
    [arScene setTracker:[arCtrl tracker]];
    
    [arCtrl setupProjection];
	
	return YES;
}



-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
	arScene = [ARScene sceneWithMarkerScale:[ARCtrl markerScale]];
    
    return arScene;
}

// doesnt work:
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
//}

- (void)createGLViewWithFrame:(CGRect)frame {
	glView = [CCGLView viewWithFrame:frame
                         pixelFormat:kEAGLColorFormatRGBA8
                         depthFormat:GL_DEPTH_COMPONENT24_OES
                  preserveBackbuffer:NO
                          sharegroup:nil
                       multiSampling:NO
                     numberOfSamples:0 ];

}

@end
