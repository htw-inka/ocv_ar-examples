/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Augmented Reality main scene header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "cocos2d.h"

#import "CCSceneAR.h"

#include "../../../../../ocv_ar/ocv_ar.h"

@interface ARScene : CCSceneAR {
    float _markerScale;  // real marker size in meters
    NSMutableDictionary *_markers;  // maps NSNumber (marker ID) -> CCNodeAR (visual marker)
}

@property (nonatomic, assign) ocv_ar::Track *tracker;   // pointer to the AR marker tracker

/**
 * Create a new AR scene and set the marker scale to <s> - static initializer.
 */
+ (ARScene *)sceneWithMarkerScale:(float)s;

/**
 * Create a new AR scene and set the marker scale to <s>.
 */
- (id)initWithMarkerScale:(float)s;

@end