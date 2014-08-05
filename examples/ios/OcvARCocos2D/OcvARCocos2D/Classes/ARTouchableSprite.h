/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Augmented Reality "touchable" sprite - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "cocos2d.h"

#import "CCSpriteAR.h"

/**
 * A CCSpriteAR child class that implements a touch event handler.
 */
@interface ARTouchableSprite : CCSpriteAR {
    CCColor *_defaultColor; // initial color
}

@end
