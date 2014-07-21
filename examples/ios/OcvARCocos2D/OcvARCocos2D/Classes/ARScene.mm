#import "ARScene.h"

#import "CCNodeAR.h"
#import "CCSpriteAR.h"

@interface ARScene (Private)
- (void)drawMarker:(const ocv_ar::Marker *)marker;
@end

@implementation ARScene

@synthesize tracker;

#pragma mark init/dealloc

+ (ARScene *)sceneWithMarkerScale:(float)s
{
	return [[self alloc] initWithMarkerScale:s];
}

- (id)initWithMarkerScale:(float)s {
    self = [super init];
    if (!self) return(nil);

    markerScale = s;
    tracker = NULL;
    
    NSLog(@"ARScene: initializing AR scene with marker scale %f", markerScale);
    
    // this will set the glClearColor
    // it is important to set the alpha channel to zero for the transparent overlay
    [self setColorRGBA:[CCColor colorWithCcColor4f:ccc4f(0.0f, 0.0f, 0.0f, 0.0f)]];
    
    // done
	return self;
}

- (void)update:(CCTime)delta {
    if (tracker) {
        tracker->update();
        
        // we'll do it like this for now and re-add the sprite for each marker on each update
        // in the future, check for added and lost markers and keep the others
        [self removeAllChildren];
        
        tracker->lockMarkers();     // lock the tracked markers, because they might get updated in a different thread
        
        // draw each marker
        const ocv_ar::MarkerMap *markers = tracker->getMarkers();
        for (ocv_ar::MarkerMap::const_iterator it = markers->begin();
             it != markers->end();
             ++it)
        {
            NSLog(@"ARScene: drawing marker #%d", it->second.getId());
            [self drawMarker:&(it->second)];
        }
        
        tracker->unlockMarkers();   // unlock the tracked markers again
    }
}

#pragma mark private methods

- (void)drawMarker:(const ocv_ar::Marker *)marker {
    // create a "AR" node
    CCNodeAR *markerNode = [CCNodeAR node];
    [markerNode setObjectId:marker->getId()];
//    [markerNode setScale:markerScale];
    
    // set the 3D transform matrix for the marker
    [markerNode setARTransformMatrix:marker->getPoseMatPtr()];
    
    // use the cocos logo as sprite for a marker
    CCSpriteAR *cocosLogo = [CCSpriteAR spriteWithImageNamed:@"Icon.png"];
    [cocosLogo setScale:markerScale];
                                                // markerScale scales down the coord. system so that 1 opengl unit
                                                // is 1 marker side length
    [markerNode addChild:cocosLogo];
    
    [self addChild:markerNode];
}

@end