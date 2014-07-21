#import "CCSceneAR.h"

#import "CCDirector.h"
#import "Tools.h"

@implementation CCSceneAR

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform {
    // override CCNode's visit:parentTransform:
    
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;
    
    [self sortAllChildren];
    
    NSLog(@"CCSceneAR - parentTransform:");
    [Tools printGLKMat4x4:parentTransform];
    
    float s = 1.0f;
	GLKMatrix4 scaleMat = GLKMatrix4MakeScale(s, s, s);
    GLKMatrix4 transform = GLKMatrix4Multiply(*parentTransform, scaleMat);
	BOOL drawn = NO;
    
	for(CCNode *child in _children){
		if(!drawn && child.zOrder >= 0){
			[self draw:renderer transform:&transform];
			drawn = YES;
		}
        
		[child visit:renderer parentTransform:&transform];
    }
    
	if(!drawn) [self draw:renderer transform:&transform];
    
	// reset for next frame
	_orderOfArrival = 0;
}

- (void) sortAllChildren
{
	if (_isReorderChildDirty)
	{
        [_children sortUsingSelector:@selector(compareZOrderToNode:)];
        
		//don't need to check children recursively, that's done in visit of each child
        
		_isReorderChildDirty = NO;
        
        [[[CCDirector sharedDirector] responderManager] markAsDirty];
        
	}
}

@end
