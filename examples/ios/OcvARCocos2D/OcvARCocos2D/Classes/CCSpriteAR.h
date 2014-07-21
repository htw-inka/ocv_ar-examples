#import "CCSprite.h"

@interface CCSpriteAR : CCSprite

// necessary override because it is private in CCNode
-(void) sortAllChildren;

@end