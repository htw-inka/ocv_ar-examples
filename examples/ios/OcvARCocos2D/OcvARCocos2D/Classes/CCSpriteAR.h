#import "CCSprite.h"
#import "CCNodeAR.h"

@interface CCSpriteAR : CCSprite {
    BOOL _position3DIsSet;
    CCNodeAR * __weak _arParent;
    GLKMatrix4 _curTransformMat;    // current global transform matrix. necessary for picking
}

@property (nonatomic, assign) GLKVector3 position3D;
@property (nonatomic, assign) float scaleZ;
@property (nonatomic, assign) float rotationalSkewZ;

// necessary override because it is private in CCNode
-(void)sortAllChildren;

-(void)setPosition3D:(GLKVector3)position3D;

-(BOOL)hitTest3DWithTouchPoint:(CGPoint)pos;

@end