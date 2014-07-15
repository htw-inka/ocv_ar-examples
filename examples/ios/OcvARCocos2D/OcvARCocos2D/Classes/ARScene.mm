#import "ARScene.h"

@implementation CCNode (ZVertex)

- (void)setZVertex:(float)zVert {
    _vertexZ = zVert;
}

@end



@implementation ARScene

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
    
    NSLog(@"initializing AR scene with marker scale %f", markerScale);
    
    // this will set the glClearColor
    // it is important to set the alpha channel to zero for the transparent overlay
    [self setColorRGBA:[CCColor colorWithCcColor4f:ccc4f(0.0f, 0.0f, 0.0f, 0.0f)]];
    [self setScale:markerScale];
    
//    // Create a colored background (Dark Grey)
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
//    [self addChild:background];
    
    CCSprite *cocosLogo = [CCSprite spriteWithImageNamed:@"Icon.png"];
//    label.positionType = CCPositionTypeNormalized;
//    label.color = [CCColor redColor];
    [cocosLogo setPositionType:CCPositionTypePoints];
    [cocosLogo setPosition:ccp(0.0f, 0.0f)];
    [cocosLogo setZVertex:-20.0f];
    
    [self addChild:cocosLogo];
    
    // done
	return self;
}


@end
