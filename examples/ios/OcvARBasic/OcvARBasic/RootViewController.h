

#import <UIKit/UIKit.h>

#import <opencv2/highgui/cap_ios.h>

#include "../../../../ocv_ar/ocv_ar.h"

#import "Tools.h"
//#import "GLView.h"


#define MARKER_REAL_SIZE_M  0.042f
#define CAM_INTRINSICS_FILE @"ipad3-front.xml"
#define PROJ_FLIP_MODE      FLIP_V

using namespace cv;
using namespace ocv_ar;

@interface RootViewController : UIViewController<CvVideoCameraDelegate> {
    CvVideoCamera *cam;
    
    UIView *baseView;
    UIImageView *frameView;
//    GLView *glView;
    
    Detect *detector;
    
    BOOL useDistCoeff;
}

@end
