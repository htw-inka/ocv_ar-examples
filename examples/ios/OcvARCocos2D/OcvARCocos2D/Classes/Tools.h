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

+ (void)printGLKMat4x4:(const GLKMatrix4 *)mat;

@end
