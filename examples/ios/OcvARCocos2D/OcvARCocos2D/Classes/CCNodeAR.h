/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * CCNode extension for AR - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "cocos2d.h"

/**
 * CCNodeAR extends CCNode by methods for augmented reality, such as an 3D AR transform matrix
 * and a 3D hit test.
 */
@interface CCNodeAR : CCNode {
    float _arTransformMat[16];          // OpenGL transform matrix for an AR marker
    GLKMatrix4 _arTransformGLKMat;      // GLKMatrix4 of the above
    
    GLKMatrix4 _projMat;                // projection matrix. necessary for picking (user interaction)
    GLKVector4 _glViewportSpecs;        // OpenGL viewport specifications. necessary for picking (user interaction)
    
    BOOL _initializedForUserInteraction;// becomes YES after initForUserInteraction was called
}

@property (nonatomic, assign) float scaleZ; // additional scaling in z direction
@property (nonatomic, assign) int objectId; // used later to identify nodes that belong to a certain marker id
@property (nonatomic, assign, getter = isAlive) BOOL alive; // should be set to YES after transform matrix was updated. will be reset on each visit. is used in ARScene
@property (nonatomic, assign) float userInteractionRadiusFactor;    // can be used to increase or decrease the user interaction area

/**
 * Set the 3D transform matrix <m>.
 */
-(void)setARTransformMatrix:(const float [16])m;

/**
 * Return a pointer to the 3D transform matrix.
 */
-(const GLKMatrix4 *)arTransformMatrixPtr;

/**
 * Must be called before user interactions (touches) can be handled.
 */
-(BOOL)initForUserInteraction;

/**
 * Make a 3D hit test ("picking") via ray projection from the screen point at <pos> into the
 * 3D scene using <transMat>. If <transMat> is nil, the current 3D transform matrix
 * <_arTransformGLKMat> will be used.
 */
-(BOOL)hitTest3DWithTouchPoint:(CGPoint)pos useTransform:(const GLKMatrix4 *)transMat;

@end
