/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Augmented Reality controller header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "cocos2d.h"

#include "../../../../../ocv_ar/ocv_ar.h"

#import "CamView.h"

// change to following lines to adjust to your setting:

#define MARKER_REAL_SIZE_M  0.042f
#define CAM_SESSION_PRESET  AVCaptureSessionPresetHigh
#define USE_DIST_COEFF      NO
#define PROJ_FLIP_MODE      ocv_ar::FLIP_H

/**
 * Augmented Reality controller. Camera and AR system management and views.
 */
@interface ARCtrl : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate, CCDirectorDelegate> {
    CGRect _baseFrame;                          // full screen frame
    UIInterfaceOrientation _interfOrientation;  // interface orientation
    
    NSString *_camIntrinsicsFile;   // camera intrinsics XML file
    
    CamView *_camView;              // shows the grabbed video frames ("camera preview")
    UIImageView *_procFrameView;    // view for processed frames
    
    AVCaptureSession *_camSession;              // controlls the camera session
    AVCaptureDeviceInput *_camDeviceInput;      // input device: camera
    AVCaptureVideoDataOutput *_vidDataOutput;   // controlls the video output
    
    cv::Mat _curFrame;          // currently grabbed camera frame (grayscale)
    cv::Mat *_dispFrame;        // frame to display. is NULL when the "normal" camera preview is displayed
    
    float _vidFrameAspRatio;    // video frame aspect ratio
    
    CCDirector *_director;  // shortcut to CCDirector shared object
    
    BOOL _useDistCoeff;     // use distortion coefficients in camera intrinsics?
    BOOL _arSysReady;       // AR system ready?
}

@property (nonatomic, readonly) UIView *baseView;           // root view for camera view, proc. frame view and gl view
@property (nonatomic, readonly) ocv_ar::Detect *detector;   // ocv_ar::Detector for marker detection
@property (nonatomic, readonly) ocv_ar::Track *tracker;     // ocv_ar::Track for marker tracking and motion interpolation
@property (nonatomic, weak) CCScene *mainScene;             // main AR display scene

/**
 * Initializer that sets the base frame to <frame> and orientation <o>.
 */
- (id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o;

/**
 * set projection to "custom projection" and set the CCDirectorDelegate to self
 * this will cause the CCDirector to call the "updateProjection" on this object
 */
- (void)setupProjection;

/**
 * should be called when the interface orientation changes. will inform the camera view
 */
- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o;

/**
 * start camera capture
 */
- (void)startCam;

/**
 * stop camera capture
 */
- (void)stopCam;

/**
 * marker scale corresponds to setting MARKER_REAL_SIZE_M
 */
+ (float)markerScale;

/**
 * OpenGL 4x4 projection matrix for AR display
 */
+ (const GLKMatrix4 *)arProjectionMatrix;

/**
 * OpenGL view frame with that takes the videos aspect ratio into account. pixel units.
 */
+ (CGRect)correctedGLViewFramePx;

/**
 * OpenGL view frame with that takes the videos aspect ratio into account. UI units.
 */
+ (CGRect)correctedGLViewFrameUnits;

@end
