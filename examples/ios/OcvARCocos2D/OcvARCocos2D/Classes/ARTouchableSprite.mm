#import "ARTouchableSprite.h"

@implementation ARTouchableSprite

#pragma mark user interaction

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    UIView *glView = [[CCDirector sharedDirector] view];
    
//    CGRect glViewFrame = glView.frame;
//    
//    NSLog(@"ARTouchableSprite: gl view frame: %d,%d - %dx%d", (int)glViewFrame.origin.x, (int)glViewFrame.origin.y,
//                                                              (int)glViewFrame.size.width, (int)glViewFrame.size.height);
    
    
    CGPoint uiLocation = [touch locationInView:glView];
//    NSLog(@"ARTouchableSprite: touch at location %d,%d", (int)uiLocation.x, (int)uiLocation.y);
//    CGPoint ccLocation = [touch locationInNode:self];
    
//    NSLog(@"touch at UI location: %d,%d / CC location: %d,%d", (int)uiLocation.x, (int)uiLocation.y,
//                                                               (int)ccLocation.x, (int)ccLocation.y);
    
    BOOL hit = [super arHitTestWithTouchPoint:uiLocation];
    
    NSLog(@"ARTouchableSprite: hit = %d", hit);
}

@end
