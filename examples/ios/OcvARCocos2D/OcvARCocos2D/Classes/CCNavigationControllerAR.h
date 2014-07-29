#import <Foundation/Foundation.h>

#import "CCDirector.h"
#import "CCAppDelegate.h"
#import "ARCtrl.h"

@interface CCNavigationControllerAR : CCNavigationController {
    CCAppDelegate* __weak _appDelegateAR;
    NSString* _screenOrientationAR;
}

@property (nonatomic, weak) CCAppDelegate* appDelegateAR;
@property (nonatomic, strong) NSString* screenOrientationAR;
@property (nonatomic, readonly) GLKVector4 glViewportSpecs;

@end

