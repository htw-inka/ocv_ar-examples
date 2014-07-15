#import "cocos2d.h"


@interface CCNode(ZVertex)
-(void)setZVertex:(float)zVert;
@end


@interface ARScene : CCScene {
    float markerScale;
}

+ (ARScene *)sceneWithMarkerScale:(float)s;
- (id)initWithMarkerScale:(float)s;

@end