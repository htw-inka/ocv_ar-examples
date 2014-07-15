#import "cocos2d.h"

#include "../../../../../ocv_ar/ocv_ar.h"

@interface CCNode(ZVertex)
-(void)setZVertex:(float)zVert;
@end


@interface ARScene : CCScene {
    float markerScale;
}

@property (nonatomic, assign) ocv_ar::Track *tracker;

+ (ARScene *)sceneWithMarkerScale:(float)s;
- (id)initWithMarkerScale:(float)s;

@end