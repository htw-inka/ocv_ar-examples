#import "cocos2d.h"

@interface CCNodeAR : CCNode {
    float _arTransformMat[16];       // OpenGL transform matrix for an AR marker
    GLKMatrix4 _arTransformGLKMat;   // GLKMatrix4 of the above
    
    GLKMatrix4 _projMat;            // projection matrix. necessary for picking (user interaction)
    GLKVector4 _glViewportSpecs;    // OpenGL viewport specifications. necessary for picking (user interaction)
    
    BOOL _initializedForUserInteraction;
}

@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) int objectId; // used later to identify nodes that belong to a certain marker id
@property (nonatomic, assign) float userInteractionRadiusFactor;
//@property (nonatomic, assign) GLKVector3 arTranslationVec;

-(void)setARTransformMatrix:(const float [16])m;
-(const GLKMatrix4 *)arTransformMatrixPtr;

-(BOOL)initForUserInteraction;

-(BOOL)hitTest3DWithTouchPoint:(CGPoint)pos useTransform:(const GLKMatrix4 *)useTransMat;

@end
