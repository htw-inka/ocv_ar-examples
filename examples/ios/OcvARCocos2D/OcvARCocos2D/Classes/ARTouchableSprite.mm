/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Augmented Reality "touchable" sprite - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "ARTouchableSprite.h"

@implementation ARTouchableSprite

#pragma mark user interaction

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    UIView *glView = [[CCDirector sharedDirector] view];
    
    // transform UIView touch coordinates to location specific coordinates
    CGPoint uiLocation = [touch locationInView:glView];
    
    // make a hit test calling CCSpriteAR's 3D hit test method
    BOOL hit = [super hitTest3DWithTouchPoint:uiLocation];
    
    NSLog(@"ARTouchableSprite: hit = %d", hit);
    
    // change the color on a successful hit
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
