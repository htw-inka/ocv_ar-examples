#import "cocos2d.h"

#import "CCSceneAR.h"

#include "../../../../../ocv_ar/ocv_ar.h"

@interface ARScene : CCSceneAR {
    float _markerScale;  // real marker size in meters
    NSMutableDictionary *_markers;  // maps NSNumber (marker ID) -> CCNodeAR (visual marker)
}

@property (nonatomic, assign) ocv_ar::Track *tracker;   // pointer to the AR marker tracker

+ (ARScene *)sceneWithMarkerScale:(float)s;
- (id)initWithMarkerScale:(float)s;

@end