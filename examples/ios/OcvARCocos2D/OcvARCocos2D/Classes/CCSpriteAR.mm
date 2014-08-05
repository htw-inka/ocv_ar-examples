/**
 * OcvARCocos2D - Marker-based Augmented Reality with ocv_ar and Cocos2D.
 *
 * CCSprite extension for AR - implementation file.
 *
 * Author: Markus Konrad <konrad@htw-berlin.de>, August 2014.
 * INKA Research Group, HTW Berlin - http://inka.htw-berlin.de/
 *
 * See LICENSE for license.
 */

#import "CCSpriteAR.h"

#import "CCNodeAR.h"
#import "Tools.h"

@implementation CCSpriteAR

@synthesize scaleZ = _scaleZ;
@synthesize rotationalSkewZ = _rotationalSkewZ;
@synthesize position3D = _position3D;

#pragma mark parent methods

-(id) initWithTexture:(CCTexture*)texture rect:(CGRect)rect rotated:(BOOL)rotated {
    // this is the designated initializer for CCSprite.
    // took me long to find that out...
    
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    if (self) {
        // set defaults
        _scaleZ = 1.0f;
        _rotationalSkewZ = 0.0f;
        _position3DIsSet = NO;
        _arParent = NULL;
    }
    
    return self;
}

-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    if (!_parent) {
        NSLog(@"CCSpriteAR: parent node must be set to a 'CCNodeAR' *before* calling 'setUserInteractionEnabled'");
        return;
    }
    
    if (![_parent isKindOfClass:[CCNodeAR class]]) {
        NSLog(@"CCSpriteAR: parent node must be of type 'CCNodeAR' for hit test");
        return;
    }
    
    // init user interaction in parent node of type CCNodeAR
    _arParent = (CCNodeAR *)_parent;
    if ([_arParent initForUserInteraction]) {
        [super setUserInteractionEnabled:userInteractionEnabled];
    }
}

-(void)setScale:(float)scale {
    _scaleZ = scale;
    [super setScale:scale];
}

-(void)setRotation:(float)rotation {
    _rotationalSkewZ = rotation;
    [super setRotation:rotation];
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform {
    // override CCNode's visit:parentTransform:
    
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;
    
    [self sortAllChildren];
    
    // apply transformations
    GLKMatrix4 transform = *parentTransform;
    
    // 1. translate
    if (_position3DIsSet) {
        transform = GLKMatrix4Translate(transform, _position3D.x, _position3D.y, _position3D.z);
    } else {
        transform = GLKMatrix4Translate(transform, _position.x, _position.y, 0.0f);
    }
    
    // 2. rotate
    transform = GLKMatrix4RotateX(transform, CC_DEGREES_TO_RADIANS(_rotationalSkewX));
    transform = GLKMatrix4RotateY(transform, CC_DEGREES_TO_RADIANS(_rotationalSkewY));
    transform = GLKMatrix4RotateZ(transform, CC_DEGREES_TO_RADIANS(_rotationalSkewZ));

    // 3. scale
    transform = GLKMatrix4Scale(transform, _scaleX, _scaleY, _scaleZ);
    
//    NSLog(@"CCSpriteAR - transform:");
//    [Tools printGLKMat4x4:&transform];
    
    @synchronized(self) {   // synchronized with "hitTest3DWithTouchPoint" method
        _curTransformMat = transform;
    }
    
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
    
    // vertex corners from anchor point
    float aL = -_anchorPoint.x;
    float aR =  _anchorPoint.x;
    float aB = -_anchorPoint.y;
    float aT =  _anchorPoint.y;
    
    // set the vertices
    CCVertex vBL { GLKVector4Make(aL, aB, _vertexZ, 1.0f),
                   verts->bl.texCoord1, verts->bl.texCoord2,
                   verts->bl.color };
    CCVertex vBR { GLKVector4Make(aR, aB, _vertexZ, 1.0f),
        verts->br.texCoord1, verts->br.texCoord2,
        verts->br.color };
    CCVertex vTR { GLKVector4Make(aR, aT, _vertexZ, 1.0f),
        verts->tr.texCoord1, verts->tr.texCoord2,
        verts->tr.color };
    CCVertex vTL { GLKVector4Make(aL, aT, _vertexZ, 1.0f),
        verts->tl.texCoord1, verts->tl.texCoord2,
        verts->tl.color };
    
    // set the vertices in the buffer
	CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:0];
	CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(vBL, transform));
	CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(vBR, transform));
	CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(vTR, transform));
	CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(vTL, transform));
	
	CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
	CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

#pragma mark public methods

-(BOOL)hitTest3DWithTouchPoint:(CGPoint)pos {
    if (!self.userInteractionEnabled || !_arParent) {
        NSLog(@"CCSpriteAR: no hit test, because user interaction is not enabled or parent node is invalid");
        return NO;
    }
    
    // make a hit test and use this sprite's full transform information for it
    
    GLKMatrix4 transform;
    @synchronized(self) {   // synchronized with visit:parentTransform:
        transform = _curTransformMat;
    }
    
    return [_arParent hitTest3DWithTouchPoint:pos useTransform:&transform];
}

-(void)setPosition3D:(GLKVector3)position3D {
    _position3D = position3D;
    _position3DIsSet = YES;
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
