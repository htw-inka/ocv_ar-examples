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


@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
		// Show the FPS and draw call label.
		CCSetupShowDebugStats: @(YES),
		
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
		CCSetupPixelFormat: kEAGLColorFormatRGBA8,  // RGBA8 is needed for transparent overlay
		// Use a simplified coordinate system that is shared across devices.
		CCSetupScreenMode: CCScreenModeFixed,
		// Run in portrait mode.
		CCSetupScreenOrientation: CCScreenOrientationLandscape,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//		CCSetupTabletScale2X: @(YES),
	}];
    
    CCDirector *director = [CCDirector sharedDirector];
    [director.view setOpaque:NO];   // needed for transparent overlay
    
    // "viewSize" returns the wrong px size (512x384), so we use viewSizeInPixels
    NSLog(@"view size: %dx%d", (int)director.viewSizeInPixels.width, (int)director.viewSizeInPixels.height);
    
    arCtrl = [[ARCtrl alloc] initWithFrame:CGRectMake(0, 0, director.viewSizeInPixels.width / 2.0f, director.viewSizeInPixels.height / 2.0f)
                               orientation:window_.rootViewController.interfaceOrientation];
    
    [arCtrl startCam];  // must be called before the subsequent commands
    
    // the "baseView" contains the camera view
    UIView *baseView = arCtrl.baseView;
    [baseView addSubview:director.view];    // add the cocos2d opengl on top of the camera view
    // replace cocos2d opengl view by "baseView" with camera view and opengl overlay
    [self.window.rootViewController setView:baseView];
    
    [arScene setTracker:[arCtrl tracker]];
	
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

@end
