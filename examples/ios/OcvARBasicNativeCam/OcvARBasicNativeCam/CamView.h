//
//  CamView.h
//  OcvARBasicNativeCam
//
//  Created by Markus Konrad on 19.06.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface CamView : UIView

@property (nonatomic) AVCaptureSession *session;

@end
