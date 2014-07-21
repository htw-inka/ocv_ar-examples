#import "CCSpriteAR.h"

#import "CCDirector.h"
#import "Tools.h"

@implementation CCSpriteAR

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform {
    // override CCNode's visit:parentTransform:
    
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;
    
    [self sortAllChildren];
    
    NSLog(@"CCSpriteAR - parentTransform:");
    [Tools printGLKMat4x4:parentTransform];
    
    
	GLKMatrix4 scaleMat = GLKMatrix4MakeScale(_scaleX, _scaleX, _scaleX);
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

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    const CCSpriteVertexes *verts = [self vertexes];
    
    CCVertex vBL { GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f),
                   verts->bl.texCoord1, verts->bl.texCoord2,
                   verts->bl.color };
    CCVertex vBR { GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f),
        verts->br.texCoord1, verts->br.texCoord2,
        verts->br.color };
    CCVertex vTR { GLKVector4Make(1.0f, 1.0f, 0.0f, 1.0f),
        verts->tr.texCoord1, verts->tr.texCoord2,
        verts->tr.color };
    CCVertex vTL { GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f),
        verts->tl.texCoord1, verts->tl.texCoord2,
        verts->tl.color };
    
	CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:0];
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(vBL, transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(vBR, transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(vTR, transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(vTL, transform));
	
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
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
