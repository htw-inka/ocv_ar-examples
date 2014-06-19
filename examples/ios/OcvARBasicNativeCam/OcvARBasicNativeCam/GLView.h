
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#include "helper/shader.h"
#include "../../../../ocv_ar/ocv_ar.h"

using namespace cv;
using namespace std;

@interface GLView : GLKView {
    BOOL glInitialized;
    
    Shader markerDispShader;
    
    GLint shAttrPos;
    
    GLint shMarkerProjMat;
    GLint shMarkerModelViewMat;
    GLint shMarkerTransformMat;
    GLint shMarkerColor;
    
    CGSize viewportSize;
    
    GLfloat markerScaleMat[16];
}

@property (nonatomic, assign) vector<ocv_ar::Marker *> markers;
@property (nonatomic, assign) float *markerProjMat;   // 4x4 projection matrix
@property (nonatomic, assign) float markerScale;
@property (nonatomic, assign) BOOL showMarkers;

- (void)setMarkerScale:(float)s;

- (void)resizeView:(CGSize)size;

@end
