//
//  IntroScene.h
//  OcvARCocos2D
//
//  Created by Markus Konrad on 08.07.14.
//  Copyright INKA Research Group 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using cocos2d-v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

#include "../../../../../ocv_ar/ocv_ar.h"

// change to following lines to adjust to your setting:

#define MARKER_REAL_SIZE_M  0.042f
#define CAM_INTRINSICS_FILE @"ipad3-front.xml"
#define CAM_SESSION_PRESET  AVCaptureSessionPresetHigh
#define USE_DIST_COEFF      NO
#define PROJ_FLIP_MODE      ocv_ar::FLIP_H


// -----------------------------------------------------------------------

/**
 *  The intro scene
 *  Note, that scenes should now be based on CCScene, and not CCLayer, as previous versions
 *  Main usage for CCLayer now, is to make colored backgrounds (rectangles)
 *
 */
@interface IntroScene : CCScene {
    ocv_ar::Detect *detector;   // ocv_ar::Detector for marker detection
    ocv_ar::Track *tracker;     // ocv_ar::Track for marker tracking and motion interpolation
    BOOL useDistCoeff;      // use distortion coefficients in camera intrinsics?
}

// -----------------------------------------------------------------------

+ (IntroScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
@end