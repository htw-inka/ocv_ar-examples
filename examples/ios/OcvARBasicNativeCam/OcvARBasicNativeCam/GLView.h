/**
 * OcvARBasicNativeCam - Basic ocv_ar example for iOS with native camera usage
 *
 * gl view - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

#include "helper/shader.h"
#include "../../../../ocv_ar/ocv_ar.h"

using namespace cv;
using namespace std;

/**
 * GLView highlights the found markers according to their estimated 3D pose.
 * It sits above the camera frame view and is not opaque.
 */
@interface GLView : GLKView {
    BOOL glInitialized;
    
    Shader markerDispShader;    // marker display shader
    
    GLint shAttrPos;            // shader attribute: vertex data
    
    GLint shMarkerProjMat;      // shader uniform: projection matrix
    GLint shMarkerModelViewMat; // shader uniform: model-view matrix
    GLint shMarkerTransformMat; // shader uniform: transform matrix
    GLint shMarkerColor;        // shader uniform: marker color
    
    CGSize viewportSize;        // real gl viewport size in pixels
    
    GLfloat markerScaleMat[16]; // global marker transform (scale) matrix
}

//@property (nonatomic, assign) vector<ocv_ar::Marker *> markers; // found markers
@property (nonatomic, assign) ocv_ar::Track *tracker;
@property (nonatomic, assign) float *markerProjMat;             // 4x4 projection matrix
@property (nonatomic, assign) float markerScale;                // marker scaling
@property (nonatomic, assign) BOOL showMarkers;                 // enable/disable marker display

/**
 * set a marker scale <s> (real marker side length in meters)
 * overwrite 'assign' method
 */
- (void)setMarkerScale:(float)s;

/**
 * Resize the gl view and adjust gl properties
 */
- (void)resizeView:(CGSize)size;

/**
 * redraw the frame (will just call [self display])
 */
- (void)render:(CADisplayLink *)displayLink;

@end
