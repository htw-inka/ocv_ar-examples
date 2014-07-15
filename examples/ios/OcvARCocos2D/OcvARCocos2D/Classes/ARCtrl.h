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

#import "CamView.h"

#define CAM_SESSION_PRESET  AVCaptureSessionPresetHigh

@interface ARCtrl : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
    CGRect baseFrame;
    UIInterfaceOrientation interfOrientation;
    
    AVCaptureSession *camSession;               // controlls the camera session
    AVCaptureDeviceInput *camDeviceInput;       // input device: camera
    AVCaptureVideoDataOutput *vidDataOutput;    // controlls the video output
    
    cv::Mat curFrame;           // currently grabbed camera frame (grayscale)
    cv::Mat *dispFrame;         // frame to display. is NULL when the "normal" camera preview is displayed
}

@property (nonatomic, readonly) UIView *baseView;
@property (nonatomic, readonly) CamView *camView;   // shows the grabbed video frames ("camera preview")


- (id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o;

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o;

- (void)startCam;
- (void)stopCam;

@end
