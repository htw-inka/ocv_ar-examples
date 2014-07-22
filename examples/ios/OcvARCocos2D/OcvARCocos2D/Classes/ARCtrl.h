//
//  ARCtrl.h
//  OcvARCocos2D
//
//  Created by Markus Konrad on 15.07.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "cocos2d.h"

#include "../../../../../ocv_ar/ocv_ar.h"

#import "CamView.h"

// change to following lines to adjust to your setting:

#define MARKER_REAL_SIZE_M  0.042f
#define CAM_INTRINSICS_FILE @"ipad3-front.xml"
#define CAM_SESSION_PRESET  AVCaptureSessionPresetHigh
#define USE_DIST_COEFF      NO
#define PROJ_FLIP_MODE      ocv_ar::FLIP_H

@interface ARCtrl : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate, CCDirectorDelegate> {
    CGRect baseFrame;
    UIInterfaceOrientation interfOrientation;
    
    AVCaptureSession *camSession;               // controlls the camera session
    AVCaptureDeviceInput *camDeviceInput;       // input device: camera
    AVCaptureVideoDataOutput *vidDataOutput;    // controlls the video output
    
    cv::Mat curFrame;           // currently grabbed camera frame (grayscale)
    cv::Mat *dispFrame;         // frame to display. is NULL when the "normal" camera preview is displayed
    
    float vidFrameAspRatio;     // video frame aspect ratio
    
    CCDirector *director;
    
    BOOL useDistCoeff;      // use distortion coefficients in camera intrinsics?
    BOOL arSysReady;
}

@property (nonatomic, readonly) UIView *baseView;
@property (nonatomic, readonly) CamView *camView;   // shows the grabbed video frames ("camera preview")
@property (nonatomic, readonly) ocv_ar::Detect *detector;   // ocv_ar::Detector for marker detection
@property (nonatomic, readonly) ocv_ar::Track *tracker;     // ocv_ar::Track for marker tracking and motion interpolation


- (id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o;

- (void)setupProjection;

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o;

- (void)startCam;
- (void)stopCam;

+ (float)markerScale;

+ (const GLKMatrix4 *)arProjectionMatrix;
+ (CGRect)correctedGLViewFrame;

@end
