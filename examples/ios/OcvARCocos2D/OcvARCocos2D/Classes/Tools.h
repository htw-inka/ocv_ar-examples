/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * Common tools - header file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

@interface Tools : NSObject

/**
 * Convert a sample buffer <buf> from the camera (YUV 4:2:0 [NV12] pixel format) to an
 * OpenCV <mat> that will contain only the luminance (grayscale) data
 * See http://www.fourcc.org/yuv.php#NV12 and https://wiki.videolan.org/YUV/#NV12.2FNV21
 * for details about the pixel format
 */
+ (void)convertYUVSampleBuffer:(CMSampleBufferRef)buf toGrayscaleMat:(cv::Mat &)mat;

/**
 * Convert cv::mat image data to UIImage
 * code from Patrick O'Keefe (http://www.patokeefe.com/archives/721)
 */
+ (UIImage *)imageFromCvMat:(const cv::Mat *)mat;

/**
 * Get the full device name such as "ipad2,1".
 */
+ (NSString *)deviceModel;

/**
 * Get the short device name such as "ipad2".
 */
+ (NSString *)deviceModelShort;

/**
 * Print a GLKMatrix4 <mat> to the console.
 */
+ (void)printGLKMat4x4:(const GLKMatrix4 *)mat;

@end
