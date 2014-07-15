#import "ARScene.h"

@implementation CCNodeAR

@synthesize objectId;

-(void)setTransformMatrix:(const float [16])m {
    memcpy(transformMat, m, 16 * sizeof(float));
}

-(GLKMatrix4)transform:(const GLKMatrix4 *)parentTransform {
    NSLog(@"CCNodeAR - object id %d, scale %f", objectId, _scaleX);
    
    GLKMatrix4 m = GLKMatrix4MakeWithArray(transformMat);
    
//    return m;
    return GLKMatrix4Scale(m, _scaleX, _scaleX, _scaleX);
}

@end


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
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);

    markerScale = s;
    tracker = NULL;
    
    NSLog(@"ARScene: initializing AR scene with marker scale %f", markerScale);
    
    // this will set the glClearColor
    // it is important to set the alpha channel to zero for the transparent overlay
    [self setColorRGBA:[CCColor colorWithCcColor4f:ccc4f(0.0f, 0.0f, 0.0f, 0.0f)]];
//    [self setScale:markerScale];
    
//    // Create a colored background (Dark Grey)
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
//    [self addChild:background];
    
//    CCSprite *cocosLogo = [CCSprite spriteWithImageNamed:@"Icon.png"];
////    label.positionType = CCPositionTypeNormalized;
////    label.color = [CCColor redColor];
//    [cocosLogo setPositionType:CCPositionTypePoints];
//    [cocosLogo setPosition:ccp(0.0f, 0.0f)];
////    [cocosLogo setZVertex:-20.0f];
    
//    [self addChild:cocosLogo];
    
    // done
	return self;
}

- (void)update:(CCTime)delta {
    if (tracker) {
        tracker->update();
        
        [self removeAllChildren];   // todo: don't do this allways
        
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
    CCNodeAR *markerNode = [CCNodeAR node];
    [markerNode setObjectId:marker->getId()];
    [markerNode setScale:markerScale];
    [markerNode setTransformMatrix:marker->getPoseMatPtr()];
    CCSprite *cocosLogo = [CCSprite spriteWithImageNamed:@"Icon.png"];
    [markerNode addChild:cocosLogo];
    
    [self addChild:markerNode];
}

@end
