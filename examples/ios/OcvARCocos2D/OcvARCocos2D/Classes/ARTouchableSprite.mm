#import "ARTouchableSprite.h"

@implementation ARTouchableSprite

#pragma mark user interaction

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    UIView *glView = [[CCDirector sharedDirector] view];
    
    CGPoint uiLocation = [touch locationInView:glView];
    BOOL hit = [super hitTest3DWithTouchPoint:uiLocation];
    
    NSLog(@"ARTouchableSprite: hit = %d", hit);
    
//    if (hit) {
//        [self setColor:[CCColor redColor]];
//    }
}

@end
