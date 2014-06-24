/**
 * OcvARBasicNativeCam - Basic ocv_ar example for iOS with native camera usage
 *
 * Misc. common functions - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, June 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * BSD licensed (see LICENSE file).
 */

#import "Tools.h"

@implementation Tools

+ (UIImage *)imageFromCvMat:(const cv::Mat *)mat {
    // code from Patrick O'Keefe (http://www.patokeefe.com/archives/721)
    NSData *data = [NSData dataWithBytes:mat->data length:mat->elemSize() * mat->total()];
    
    CGColorSpaceRef colorSpace;
    
    if (mat->elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(mat->cols,                                 //width
                                        mat->rows,                                 //height
                                        8,                                          //bits per component
                                        8 * mat->elemSize(),                       //bits per pixel
                                        mat->step.p[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
    
}

+ (cv::Mat *)cvMatFromImage:(const UIImage *)img gray:(BOOL)gray {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(img.CGImage);

    const int w = [img size].width;
    const int h = [img size].height;
    
    // create cv::Mat
    cv::Mat *mat = new cv::Mat(h, w, CV_8UC4);
    
    // create context
    CGContextRef contextRef = CGBitmapContextCreate(mat->ptr(),
                                                    w, h,
                                                    8,
                                                    mat->step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    if (!contextRef) {
        delete mat;
        
        return NULL;
    }
    
    // draw the image in the context
    CGContextDrawImage(contextRef, CGRectMake(0, 0, w, h), img.CGImage);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // convert to grayscale data if necessary
    if (gray) {
        cv::Mat *grayMat = new cv::Mat(h, w, CV_8UC1);
        cv::cvtColor(*mat, *grayMat, CV_RGBA2GRAY);
        delete mat;
        
        return grayMat;
    }
    
    return mat;
}

+ (CGImageRef)CGImageFromCvMat:(const cv::Mat &)mat {
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize() * mat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(mat.cols,                                   //width
                                        mat.rows,                                   //height
                                        8,                                          //bits per component
                                        8 * mat.elemSize(),                         //bits per pixel
                                        mat.step.p[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,//bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return imageRef;
}

+ (void)convertYUVSampleBuffer:(CMSampleBufferRef)buf toMat:(cv::Mat &)mat {
    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(buf);
    
    // lock the buffer
    CVPixelBufferLockBaseAddress(imgBuf, 0);
    
    // get the address to the image data
//    void *imgBufAddr = CVPixelBufferGetBaseAddress(imgBuf);   // this is wrong! see http://stackoverflow.com/a/4109153
    void *imgBufAddr = CVPixelBufferGetBaseAddressOfPlane(imgBuf, 0);
    
    // get image properties
    size_t w = CVPixelBufferGetWidth(imgBuf);
    size_t h = CVPixelBufferGetHeight(imgBuf);
    
    // create the cv mat
    mat.create(h, w, CV_8UC1);              // 8 bit unsigned chars for grayscale data
    memcpy(mat.data, imgBufAddr, w * h);    // the first plane contains the grayscale data
                                            // therefore we use <imgBufAddr> as source
    
    // unlock again
    CVPixelBufferUnlockBaseAddress(imgBuf, 0);
}

@end
