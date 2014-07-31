#import "CCSprite.h"

@interface CCSpriteAR : CCSprite {
    BOOL _position3DIsSet;
}

@property (nonatomic, assign) GLKVector3 position3D;
@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) float rotationalSkewZ;

// necessary override because it is private in CCNode
-(void) sortAllChildren;

- (BOOL)arHitTestWithTouchPoint:(CGPoint)pos;

-(void)setPosition3D:(GLKVector3)position3D;

@end