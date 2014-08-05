#import "ARTouchableSprite.h"

@implementation ARTouchableSprite

#pragma mark user interaction

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    UIView *glView = [[CCDirector sharedDirector] view];
    
    CGPoint uiLocation = [touch locationInView:glView];
    BOOL hit = [super hitTest3DWithTouchPoint:uiLocation];
    
    NSLog(@"ARTouchableSprite: hit = %d", hit);
    
    if (hit) {
        if (!_defaultColor) {
            _defaultColor = [CCColor colorWithCcColor3b:self.color.ccColor3b];
            [self setColor:[CCColor redColor]];
        } else {
            [self setColor:[CCColor colorWithCcColor3b:_defaultColor.ccColor3b]];
            _defaultColor = nil;
        }
    }
}

@end
