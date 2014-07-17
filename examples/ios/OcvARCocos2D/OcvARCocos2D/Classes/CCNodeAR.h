#import "cocos2d.h"

@interface CCNodeAR : CCNode {
    float arTransformMat[16];   // OpenGL transform matrix for an AR marker
}

@property (nonatomic, assign) int objectId; // used later to identify nodes that belong to a certain marker id

-(void)setARTransformMatrix:(const float [16])m;

@end
