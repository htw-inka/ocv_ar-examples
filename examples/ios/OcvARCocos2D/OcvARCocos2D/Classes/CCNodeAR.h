#import "cocos2d.h"

@interface CCNodeAR : CCNode {
    float arTransformMat[16];       // OpenGL transform matrix for an AR marker
    GLKMatrix4 arTransformGLKMat;   // GLKMatrix4 of the above
}

@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) int objectId; // used later to identify nodes that belong to a certain marker id
@property (nonatomic, assign) GLKVector3 arTranslationVec;

-(void)setARTransformMatrix:(const float [16])m;
-(const GLKMatrix4 *)arTransformMatrixPtr;

@end
