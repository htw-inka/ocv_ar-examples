#import "cocos2d.h"

#import "CCSceneAR.h"

#include "../../../../../ocv_ar/ocv_ar.h"

@interface ARScene : CCSceneAR {
    float markerScale;  // real marker size in meters
}

@property (nonatomic, assign) ocv_ar::Track *tracker;   // pointer to the AR marker tracker

+ (ARScene *)sceneWithMarkerScale:(float)s;
- (id)initWithMarkerScale:(float)s;

@end