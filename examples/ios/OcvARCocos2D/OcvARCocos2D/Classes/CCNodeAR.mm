#import "CCNodeAR.h"

@implementation CCNodeAR

@synthesize objectId;

-(void)setARTransformMatrix:(const float [16])m {
    memcpy(arTransformMat, m, 16 * sizeof(float));
}

-(void)visit:(__unsafe_unretained CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform
{
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;
    
    [self sortAllChildren];
    
    // just use the AR transform matrix directly for this node
    GLKMatrix4 transform = GLKMatrix4MakeWithArray(arTransformMat); // transpose necessary, too?
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
    // copy&paste from CCNode. necessary because this method was private and is called from
    // visit:parentTransform:
    
	if (_isReorderChildDirty)
	{
        [_children sortUsingSelector:@selector(compareZOrderToNode:)];
        
		//don't need to check children recursively, that's done in visit of each child
        
		_isReorderChildDirty = NO;
        
        [[[CCDirector sharedDirector] responderManager] markAsDirty];
        
	}
}

@end
