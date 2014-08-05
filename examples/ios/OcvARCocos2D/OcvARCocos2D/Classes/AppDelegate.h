/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * AppDelegate header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "cocos2d.h"

#import "ARCtrl.h"
#import "ARScene.h"

/**
 * Application delegate. Initializes the application on startup and handles
 * application life cycle events.
 */
@interface AppDelegate : CCAppDelegate {
    ARCtrl *_arCtrl;     // AR controller
    ARScene *_arScene;   // AR scene (CCSceneAR instance) to display the markers
    
    UIViewController *_rootViewCtrl; // root UIViewController
    
    CCGLView *_glView;   // OpenGL view from cocos2D
}

@end
