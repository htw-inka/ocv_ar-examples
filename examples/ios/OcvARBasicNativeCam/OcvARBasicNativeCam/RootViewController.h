/**
 * OcvARBasicNativeCam - Basic ocv_ar example for iOS with native camera usage
 *
 * Main view controller - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#include "../../../../ocv_ar/ocv_ar.h"

#import "CamView.h"
#import "GLView.h"

// change to following lines to adjust to your setting:

#define MARKER_REAL_SIZE_M  0.042f
#define CAM_INTRINSICS_FILE @"ipad3-front.xml"
#define CAM_SESSION_PRESET  AVCaptureSessionPresetHigh
#define USE_DIST_COEFF      NO
#define PROJ_FLIP_MODE      ocv_ar::FLIP_H

/**
 * Main view controller.
 * Handles UI initialization and interactions.
 */
@interface RootViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *camSession;               // controlls the camera session
    AVCaptureDeviceInput *camDeviceInput;       // input device: camera
    AVCaptureVideoDataOutput *vidDataOutput;    // controlls the video output
    
    cv::Mat curFrame;
    cv::Mat *dispFrame;
    
    UIView *baseView;           // root view
    UIImageView *procFrameView; // view for processed frames (only for debugging)
    CamView *camView;           // shows the grabbed video frames
    GLView *glView;             // gl view displays the highlighted markers
    
    ocv_ar::Detect *detector;       // ocv_ar::Detector for marker detection
    
    BOOL useDistCoeff;      // use distortion coefficients in camera intrinsics?
}

@end
