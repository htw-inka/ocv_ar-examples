#import "cocos2d.h"

#include "../../../../../ocv_ar/ocv_ar.h"

@interface CCNodeAR : CCNode {
    float arTransformMat[16];
}

@property (nonatomic, assign) int objectId;

-(void)setARTransformMatrix:(const float [16])m;

//-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform;

-(void)visit:(__unsafe_unretained CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform;

-(void)sortAllChildren;

@end


@interface ARScene : CCScene {
    float markerScale;
}

@property (nonatomic, assign) ocv_ar::Track *tracker;

+ (ARScene *)sceneWithMarkerScale:(float)s;
- (id)initWithMarkerScale:(float)s;

@end