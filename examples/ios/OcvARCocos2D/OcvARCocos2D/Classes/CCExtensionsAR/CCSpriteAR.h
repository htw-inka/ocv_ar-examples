/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * CCSprite extension for AR - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "CCSprite.h"
#import "CCNodeAR.h"

/**
 * CCSpriteAR extends CCSprite by methods for augmented reality, namely overriding
 * "visit:parentTransform:" and providing additional functions for 3D transformations.
 */
@interface CCSpriteAR : CCSprite {
    BOOL _position3DIsSet;  // is YES when <position3D> is used instead of CCNode's <position> for full 3D translation
    CCNodeAR * __weak _arParent;    // parent node must be of type CCNodeAR
    GLKMatrix4 _curTransformMat;    // current global transform matrix. necessary for picking
}

@property (nonatomic, assign) GLKVector3 position3D;    // a 3D position can be set when the z-coordinate is necessary
@property (nonatomic, assign) float scaleZ;             // additional scaling in z direction
@property (nonatomic, assign) float rotationalSkewZ;    // additional rotation in z direction

// necessary override because it is private in CCNode
-(void)sortAllChildren;

/**
 * Set the 3D position.
 * Overrides the default setter to additionally set <_position3DIsSet> to YES.
 */
-(void)setPosition3D:(GLKVector3)position3D;

/**
 * Make a 3D hit test ("picking"). Uses the parent's CCNodeAR's method "hitTest3DWithTouchPoint:useTransform:"
 * with <_curTransformMat> as custom transform matrix.
 */
-(BOOL)hitTest3DWithTouchPoint:(CGPoint)pos;

@end