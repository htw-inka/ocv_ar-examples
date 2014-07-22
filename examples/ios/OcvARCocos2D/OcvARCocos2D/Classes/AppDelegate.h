//
//  AppDelegate.h
//  OcvARCocos2D
//
//  Created by Markus Konrad on 08.07.14.
//  Copyright INKA Research Group 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "cocos2d.h"

#import "ARCtrl.h"
#import "ARScene.h"
#import "RootViewCtrl.h"

@interface AppDelegate : CCAppDelegate {
    ARCtrl *arCtrl;
    ARScene *arScene;
    
    RootViewCtrl *rootViewCtrl;
    
    CCGLView *glView;
}

@end
