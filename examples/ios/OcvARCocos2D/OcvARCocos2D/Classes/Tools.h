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

// create a CGImage from a cv::Mat
// you will need to distroy the returned object later!
+ (CGImageRef)CGImageFromCvMat:(const cv::Mat &)mat;

/**
 * Convert a sample buffer <buf> from the camera (YUV 4:2:0 [NV12] pixel format) to an
 * OpenCV <mat> that will contain only the luminance (grayscale) data
 * See http://www.fourcc.org/yuv.php#NV12 and https://wiki.videolan.org/YUV/#NV12.2FNV21
 * for details about the pixel format
 */
+ (void)convertYUVSampleBuffer:(CMSampleBufferRef)buf toGrayscaleMat:(cv::Mat &)mat;

@end
