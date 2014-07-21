#import "CCSprite.h"

@interface CCSpriteAR : CCSprite

@property (nonatomic, assign) float scaleZ;

// necessary override because it is private in CCNode
-(void) sortAllChildren;

@end