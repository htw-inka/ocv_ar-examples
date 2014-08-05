/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Augmented Reality main scene implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "ARScene.h"

#import "CCNodeAR.h"
#import "ARTouchableSprite.h"

@interface ARScene (Private)
/**
 * Create a new marker node with a cocos logo sprite as child.
 */
- (CCNodeAR *)createMarkerNodeWithId:(int)markerId;

/**
 * Update <markerNode> and set its properties according to <markerObj>.
 */
- (void)updateMarkerNode:(CCNodeAR *)markerNode withMarkerObj:(const ocv_ar::Marker *)markerObj;
@end

@implementation ARScene

@synthesize tracker = _tracker;

#pragma mark init/dealloc

+ (ARScene *)sceneWithMarkerScale:(float)s
{
	return [[self alloc] initWithMarkerScale:s];
}

- (id)initWithMarkerScale:(float)s {
    self = [super init];
    if (!self) return(nil);

    // init defaults
    _markerScale = s;
    _tracker = NULL;
    _markers = [[NSMutableDictionary alloc] init];
    
    NSLog(@"ARScene: initializing AR scene with marker scale %f", _markerScale);
    
    // this will set the glClearColor
    // it is important to set the alpha channel to zero for the transparent overlay
    [self setColorRGBA:[CCColor colorWithCcColor4f:ccc4f(0.0f, 0.0f, 0.0f, 0.0f)]];
    
    // done
	return self;
}

- (void)update:(CCTime)delta {
    if (!_tracker) return;
    
    // update the ocv_ar tracker
    _tracker->update();
    
    _tracker->lockMarkers();     // lock the tracked markers, because they might get updated in a different thread
    
    // update the markers dictionary
    const ocv_ar::MarkerMap *markers = _tracker->getMarkers();
    for (ocv_ar::MarkerMap::const_iterator it = markers->begin();
         it != markers->end();
         ++it)
    {
        int markerId = it->first;
        NSNumber *markerIdNum = [NSNumber numberWithInt:markerId];
        const ocv_ar::Marker *markerObj = &it->second;
        CCNodeAR *presentMarker = [_markers objectForKey:markerIdNum];
        
        if (presentMarker) { // marker is already known -> update it
            [self updateMarkerNode:presentMarker withMarkerObj:markerObj];
        } else {    // marker is not known -> create a new node for it
            presentMarker = [self createMarkerNodeWithId:markerId];
            [self updateMarkerNode:presentMarker withMarkerObj:markerObj];
            [self addChild:presentMarker];
            
            [_markers setObject:presentMarker forKey:markerIdNum];
        }
    }
    
    _tracker->unlockMarkers();   // unlock the tracked markers again
    
    // remove "dead" markers
    NSMutableArray *markerNodesToDelete = [NSMutableArray array];
    for (CCNodeAR *markerNode in _markers.allValues) {
        if (!markerNode.isAlive) {
            [markerNode removeFromParent];
            [markerNodesToDelete addObject:[NSNumber numberWithInt:markerNode.objectId]];
        }
    }
    
    [_markers removeObjectsForKeys:markerNodesToDelete];
}

#pragma mark private methods

- (CCNodeAR *)createMarkerNodeWithId:(int)markerId {
    // create a "AR" node
    CCNodeAR *markerNode = [CCNodeAR node];
    [markerNode setObjectId:markerId];
    
    [markerNode setScale:_markerScale]; // markerScale scales down the coord. system so that 1 opengl unit
                                        // is 1 marker side length
    
    // Note: 3D transform information will be set in updateMarkerNode:withMarkerObj:
    
    // use the cocos logo as sprite for a marker
    ARTouchableSprite *cocosLogo = [ARTouchableSprite spriteWithImageNamed:@"Icon.png"];
    
    // it is possible to apply transformations to a sprite in 3D:
    //    [cocosLogo setPosition:ccp(1.0f,1.0f)];
    //    [cocosLogo setRotationalSkewZ:45.0f];
    //    [cocosLogo setPosition3D:GLKVector3Make(0.0f, 0.0f, 0.75f)];
    //    [cocosLogo setScale:0.5f];
    
    // add the cocos logo sprite as child to the marker node
    [markerNode addChild:cocosLogo];
    
    // enabled touch interaction
    // this must be called *after* it has been added to a CCNodeAR
    [cocosLogo setUserInteractionEnabled:YES];
    
    return markerNode;
}

-(void)updateMarkerNode:(CCNodeAR *)markerNode withMarkerObj:(const ocv_ar::Marker *)markerObj {
    [markerNode setARTransformMatrix:markerObj->getPoseMatPtr()];   // determines the 3D transform
    [markerNode setAlive:YES];  // shows that this marker was updated lately
}

@end
