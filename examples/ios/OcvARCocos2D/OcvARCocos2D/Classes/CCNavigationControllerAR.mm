/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Special navigation controller with AR extensions - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "CCNavigationControllerAR.h"

@implementation CCNavigationControllerAR

static float _uiScreenScale = 0.0f;

@synthesize glViewportSpecs = _glViewportSpecs;
@synthesize appDelegateAR = _appDelegateAR;
@synthesize screenOrientationAR = _screenOrientationAR;

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations
{
    if ([_screenOrientationAR isEqual:CCScreenOrientationAll])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else if ([_screenOrientationAR isEqual:CCScreenOrientationPortrait])
    {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscape;
    }
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([_screenOrientationAR isEqual:CCScreenOrientationAll])
    {
        return YES;
    }
    else if ([_screenOrientationAR isEqual:CCScreenOrientationPortrait])
    {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
    else
    {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }
}

// Projection delegate is only used if the fixed resolution mode is enabled
-(GLKMatrix4)updateProjection
{
    if ([ARCtrl arProjectionMatrix]) {  // return the AR projection matrix if available
        CGRect viewportFrame = [ARCtrl correctedGLViewFramePx];
        glViewport(0.0f, 0.0f, viewportFrame.size.width, viewportFrame.size.height);
        _glViewportSpecs = GLKVector4Make(0.0f, 0.0f, viewportFrame.size.width, viewportFrame.size.height);
        
        return (*[ARCtrl arProjectionMatrix]);
    }
    
	CGSize sizePoint = [CCDirector sharedDirector].viewSize;
	CGSize fixed = [CCDirector sharedDirector].designSize;
	
	// Half of the extra size that will be cut off
	CGPoint offset = ccpMult(ccp(fixed.width - sizePoint.width, fixed.height - sizePoint.height), 0.5);
	
	return GLKMatrix4MakeOrtho(offset.x, sizePoint.width + offset.x, offset.y, sizePoint.height + offset.y, -1024, 1024);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [_appDelegateAR startScene]];
	}
}

+(float)uiScreenScale {
    if (_uiScreenScale == 0.0f) {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]) {
            _uiScreenScale = [UIScreen mainScreen].scale;
        } else {
            _uiScreenScale = 1.0f;
        }
    }
    
    return _uiScreenScale;
}

@end
