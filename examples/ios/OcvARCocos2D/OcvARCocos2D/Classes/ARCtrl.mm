//
//  ARCtrl.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 15.07.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import "ARCtrl.h"

/**
 * Small helper function to convert a fourCC <code> to
 * a character string <fourCC> for printf and the like
 */
void fourCCStringFromCode(int code, char fourCC[5]) {
    for (int i = 0; i < 4; i++) {
        fourCC[3 - i] = code >> (i * 8);
    }
    fourCC[4] = '\0';
}


@implementation ARCtrl

@synthesize camView;
@synthesize baseView;


#pragma mark init/dealloc

-(id)initWithFrame:(CGRect)frame orientation:(UIInterfaceOrientation)o {
    self = [super init];
    
    if (self) {
        baseFrame = frame;
        interfOrientation = o;
        
        baseView = [[UIView alloc] initWithFrame:baseFrame];
        
        [self initCam];
    }
    
    return self;
}

- (void)dealloc {
    [self stopCam];
}


#pragma mark public methods

- (void)startCam {
    NSLog(@"starting camera capture");
    [camSession startRunning];
}

- (void)stopCam {
    NSLog(@"stopping camera capture");
    [camSession stopRunning];
}

- (void)interfaceOrientationChanged:(UIInterfaceOrientation)o {
    interfOrientation = o;
    [[(AVCaptureVideoPreviewLayer *)camView.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)o];
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
}

#pragma mark private methods

- (void)initCam {
    NSLog(@"initializing cam");
    
    // init camera view
    camView = [[CamView alloc] initWithFrame:baseFrame];
    [baseView addSubview:camView];
    
    NSError *error = nil;
    
    // set up the camera capture session
    camSession = [[AVCaptureSession alloc] init];
    [camSession setSessionPreset:CAM_SESSION_PRESET];
    [camView setSession:camSession];
    
    // get the camera device
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count <= 0) {
        NSLog(@"error - no camera found on this device");
        return;
    }
    
	AVCaptureDevice *camDevice = [devices firstObject];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) {
			camDevice = device;
			break;
		}
	}
    
    camDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camDevice error:&error];
    
    if (error || !camDeviceInput) {
        NSLog(@"error getting camera device: %@", error);
        return;
    }
    
    // add the camera device to the session
    if ([camSession canAddInput:camDeviceInput]) {
        [camSession addInput:camDeviceInput];
        [self interfaceOrientationChanged:interfOrientation];
    }
    
    // create camera output
    vidDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [camSession addOutput:vidDataOutput];
    
    // set output delegate to self
    dispatch_queue_t queue = dispatch_queue_create("vid_output_queue", NULL);
    [vidDataOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    // get best output video format
    NSArray *outputPixelFormats = vidDataOutput.availableVideoCVPixelFormatTypes;
    int bestPixelFormatCode = -1;
    for (NSNumber *format in outputPixelFormats) {
        int code = [format intValue];
        if (bestPixelFormatCode == -1) bestPixelFormatCode = code;  // choose the first as best
        char fourCC[5];
        fourCCStringFromCode(code, fourCC);
        NSLog(@"available video output format: %s (code %d)", fourCC, code);
    }
    
    // specify output video format
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:bestPixelFormatCode]
                                                               forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [vidDataOutput setVideoSettings:outputSettings];
}

- (void)initAR {
    
}

@end
