/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Special navigation controller with AR extensions - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import <Foundation/Foundation.h>

#import "CCDirector.h"
#import "CCAppDelegate.h"
#import "ARCtrl.h"

/**
 * Implements extensions to CCNavigationController for augmented reality
 * purposes.
 */
@interface CCNavigationControllerAR : CCNavigationController {
    CCAppDelegate* __weak _appDelegateAR;
    NSString* _screenOrientationAR;
}

@property (nonatomic, weak) CCAppDelegate* appDelegateAR;
@property (nonatomic, strong) NSString* screenOrientationAR;
@property (nonatomic, readonly) GLKVector4 glViewportSpecs;

/**
 * Return the UI screen scale. For Retina displays this value is 2.
 */
+(float)uiScreenScale;

@end

