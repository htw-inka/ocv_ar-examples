/**
 * OcvARBasicNativeCam - Basic ocv_ar example for iOS with native camera usage
 *
 * Misc. common functions - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Tools : NSObject

// Convert cv::mat image data to UIImage
// code from Patrick O'Keefe (http://www.patokeefe.com/archives/721)
+ (UIImage *)imageFromCvMat:(const cv::Mat *)mat;

// get a cvMat image from an UIImage
+ (cv::Mat *)cvMatFromImage:(const UIImage *)img gray:(BOOL)gray;

+ (CGImageRef)CGImageFromCvMat:(const cv::Mat &)mat;

/**
 * Convert a sample buffer <buf> from the camera (YUV pixel format) to an
 * OpenCV <mat>
 */
+ (void)convertYUVSampleBuffer:(CMSampleBufferRef)buf toMat:(cv::Mat &)mat;

@end
