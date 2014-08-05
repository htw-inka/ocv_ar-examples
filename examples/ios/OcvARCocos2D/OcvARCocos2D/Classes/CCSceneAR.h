/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * CCScene extension for AR - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "CCScene.h"

/**
 * CCSceneAR extends CCScene by methods for augmented reality, namely overriding
 * "visit:parentTransform:"
 */
@interface CCSceneAR : CCScene

@property (nonatomic, assign) float scaleZ; // additional scaling in z direction

// necessary override because it is private in CCNode
-(void) sortAllChildren;

@end
