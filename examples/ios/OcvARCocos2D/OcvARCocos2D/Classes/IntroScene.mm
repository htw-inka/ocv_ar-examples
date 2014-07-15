//
//  IntroScene.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 08.07.14.
//  Copyright INKA Research Group 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "IntroScene.h"

@implementation CCNode (ZVertex)

- (void)setZVertex:(float)zVert {
    _vertexZ = zVert;
}

@end

@interface IntroScene(Private)

/**
 * initialize ocv_ar marker detector
 */
- (BOOL)initDetector;

@end


@implementation IntroScene

#pragma mark init/dealloc

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    useDistCoeff = USE_DIST_COEFF;
    
    // create the detector
    detector = new ocv_ar::Detect(ocv_ar::IDENT_TYPE_CODE_7X7,  // marker type
                                  MARKER_REAL_SIZE_M,           // real marker size in meters
                                  PROJ_FLIP_MODE);              // projection flip mode
    // create the tracker and pass it a reference to the detector object
    tracker = new ocv_ar::Track(detector);
    
    // init detector
    if ([self initDetector]) {
        NSLog(@"cam intrinsics loaded from file %@", CAM_INTRINSICS_FILE);
    } else {
        NSLog(@"detector initialization failure");
    }

    // register as delegate to provide a custom projection matrix later
    [[CCDirector sharedDirector] setDelegate:self];
    [[CCDirector sharedDirector] setProjection:CCDirectorProjectionCustom];
    
    [self setScale:detector->getMarkerScale()];
    
//    // Create a colored background (Dark Grey)
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
//    [self addChild:background];
    
    CCSprite *cocosLogo = [CCSprite spriteWithImageNamed:@"Icon.png"];
//    label.positionType = CCPositionTypeNormalized;
//    label.color = [CCColor redColor];
    [cocosLogo setPositionType:CCPositionTypePoints];
    [cocosLogo setPosition:ccp(0.0f, 0.0f)];
    [cocosLogo setZVertex:-20.0f];
    
    [self addChild:cocosLogo];
    
    // done
	return self;
}

- (void)dealloc {
    if (tracker) delete tracker;
    if (detector) delete detector;
}

#pragma mark private methods

- (BOOL)initDetector {
    cv::FileStorage fs;
    const char *path = [[[NSBundle mainBundle] pathForResource:CAM_INTRINSICS_FILE ofType:NULL]
                        cStringUsingEncoding:NSASCIIStringEncoding];
    
    if (!path) {
        NSLog(@"could not find cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return NO;
    }
    
    fs.open(path, cv::FileStorage::READ);
    
    if (!fs.isOpened()) {
        NSLog(@"could not load cam intrinsics file %@", CAM_INTRINSICS_FILE);
        return NO;
    }
    
    cv::Mat camMat;
    cv::Mat distCoeff;
    
    fs["Camera_Matrix"]  >> camMat;
    
    if (useDistCoeff) {
        fs["Distortion_Coefficients"]  >> distCoeff;
    }
    
    if (camMat.empty()) {
        NSLog(@"could not load cam instrinsics matrix from file %@", CAM_INTRINSICS_FILE);
        
        return NO;
    }
    
    detector->setCamIntrinsics(camMat, distCoeff);
    
    return YES;
}

#pragma mark CCDirectorDelegate methods

- (GLKMatrix4)updateProjection {
    CCDirector *director = [CCDirector sharedDirector];
    CGSize viewSize = [director viewSize];
    detector->prepare(1920, 1080, 1);
    float *projMatPtr = detector->getProjMat(viewSize.width, viewSize.height);  // retina scale?
    
    GLKMatrix4 projMat = GLKMatrix4MakeWithArray(projMatPtr);
    
    NSLog(@"updating projection matrix");
    
    return projMat;
}


@end
