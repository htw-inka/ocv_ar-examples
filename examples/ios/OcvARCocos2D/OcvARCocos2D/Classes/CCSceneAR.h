#import "CCScene.h"

@interface CCSceneAR : CCScene

@property (nonatomic, assign) float scaleZ;

// necessary override because it is private in CCNode
-(void) sortAllChildren;

@end
