/**
 * OcvARBasic - Basic ocv_ar example for iOS
 *
 * Misc. common functions - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import <Foundation/Foundation.h>

@interface Tools : NSObject

// Convert cv::mat image data to UIImage
// code from Patrick O'Keefe (http://www.patokeefe.com/archives/721)
+(UIImage *)imageFromCvMat:(cv::Mat *)mat;

// get a cvMat image from an UIImage
+(cv::Mat *)cvMatFromImage:(UIImage *)img gray:(BOOL)gray;

@end
