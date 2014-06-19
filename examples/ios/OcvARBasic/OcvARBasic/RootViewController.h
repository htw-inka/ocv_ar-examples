/**
 * OcvARBasic - Basic ocv_ar example for iOS
 *
 * Main view controller - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import <UIKit/UIKit.h>

#import <opencv2/highgui/cap_ios.h>

#include "../../../../ocv_ar/ocv_ar.h"

#import "Tools.h"
#import "GLView.h"

// change to following lines to adjust to your setting:

#define MARKER_REAL_SIZE_M  0.042f
#define CAM_INTRINSICS_FILE @"ipad3-front.xml"
#define USE_DIST_COEFF      NO
#define PROJ_FLIP_MODE      FLIP_V

using namespace cv;
using namespace ocv_ar;

/**
 * Main view controller.
 * Handles UI initialization and interactions.
 */
@interface RootViewController : UIViewController<CvVideoCameraDelegate> {
    CvVideoCamera *cam;     // for grabbing video frames
    
    UIView *baseView;       // root view
    UIImageView *frameView; // frame view shows the grabbed video frames
    GLView *glView;         // gl view displays the highlighted markers
    
    Detect *detector;       // ocv_ar::Detector for marker detection
    
    BOOL useDistCoeff;      // use distortion coefficients in camera intrinsics?
}

@end
