#import "Tools.h"

@implementation Tools

+ (void)convertYUVSampleBuffer:(CMSampleBufferRef)buf toGrayscaleMat:(cv::Mat &)mat {
    CVImageBufferRef imgBuf = CMSampleBufferGetImageBuffer(buf);
    
    // lock the buffer
    CVPixelBufferLockBaseAddress(imgBuf, 0);
    
    // get the address to the image data
//    void *imgBufAddr = CVPixelBufferGetBaseAddress(imgBuf);   // this is wrong! see http://stackoverflow.com/a/4109153
    void *imgBufAddr = CVPixelBufferGetBaseAddressOfPlane(imgBuf, 0);
    
    // get image properties
    int w = (int)CVPixelBufferGetWidth(imgBuf);
    int h = (int)CVPixelBufferGetHeight(imgBuf);
    
    // create the cv mat
    mat.create(h, w, CV_8UC1);              // 8 bit unsigned chars for grayscale data
    memcpy(mat.data, imgBufAddr, w * h);    // the first plane contains the grayscale data
                                            // therefore we use <imgBufAddr> as source
    
    // unlock again
    CVPixelBufferUnlockBaseAddress(imgBuf, 0);
}

+ (void)printGLKMat4x4:(const GLKMatrix4 *)mat {
    for (int y = 0; y < 4; ++y) {
        for (int x = 0; x < 4; ++x) {
            printf("%f ", mat->m[y * 4 + x]);
        }
        
        printf("\n");
    }
}

@end
