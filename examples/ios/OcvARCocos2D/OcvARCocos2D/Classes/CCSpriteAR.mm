#import "CCSpriteAR.h"

#import "CCDirector.h"
#import "CCNodeAR.h"
#import "CCNavigationControllerAR.h"
#import "Tools.h"

@interface CCSpriteAR (Private)
-(GLKVector3)unprojectScreenCoords:(GLKVector3)screenPt
                        mvpInverse:(const GLKMatrix4 *)mvpInvMat
                          viewport:(const GLKVector4 *)viewport;

-(BOOL)intersectionOfRayOrigin:(const GLKVector3 *)o direction:(const GLKVector3 *)d
                  sphereRadius:(float)r foundT:(float *)t;

@end

@implementation CCSpriteAR

@synthesize scaleZ = _scaleZ;

#pragma mark init/dealloc

-(id)init {
    self = [super init];
    if (self) {
        _scaleZ = 1.0f;
    }
    
    return self;
}

#pragma mark parent methods

-(void)setScale:(float)scale {
    _scaleZ = scale;
    [super setScale:scale];
}

-(void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform {
    // override CCNode's visit:parentTransform:
    
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;
    
    [self sortAllChildren];
    
//    NSLog(@"CCSpriteAR - parentTransform:");
//    [Tools printGLKMat4x4:parentTransform];
    
    
	GLKMatrix4 scaleMat = GLKMatrix4MakeScale(_scaleX, _scaleY, _scaleZ);
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

- (BOOL)arHitTestWithTouchPoint:(CGPoint)pos {
    // todo: move this to init
    if (![_parent isKindOfClass:[CCNodeAR class]]) {
        NSLog(@"CCSpriteAR: parent node must be of type 'CCNodeAR' for hit test");
        return NO;
    }
    
    CCDirector *director = [CCDirector sharedDirector];
    if (![[director delegate] isKindOfClass:[CCNavigationControllerAR class]]) {
        NSLog(@"CCSpriteAR: Navigation controller must be of type 'CCNavigationControllerAR' for hit test");
        return NO;
    }
    
    CCNodeAR *arParent = (CCNodeAR *)_parent;
    CCNavigationControllerAR *navCtrl = (CCNavigationControllerAR *)[director delegate];
    
    GLKMatrix4 projMat = director.projectionMatrix;
    GLKVector4 viewport = navCtrl.glViewportSpecs;
    
    // get current transform matrix
	GLKMatrix4 scaleMat = GLKMatrix4MakeScale(_scaleX, _scaleY, _scaleZ);
    GLKMatrix4 mvMat = GLKMatrix4Multiply(*arParent.arTransformMatrixPtr, scaleMat);
    
    // get the inverse of the model-view-projection matrix
    bool isInv;
    GLKMatrix4 mvpInvMat = GLKMatrix4Invert(GLKMatrix4Multiply(projMat, mvMat), &isInv);
    if (!isInv) {
        NSLog(@"CCSpriteAR: Could not invert MVP matrix for hit test");
        return NO;
    }
    
    // construct a ray into the 3D scene
    GLKVector3 rayPt1 = [self unprojectScreenCoords:GLKVector3Make(pos.x, pos.y, 0.0f)
                                         mvpInverse:&mvpInvMat
                                           viewport:&viewport];
    GLKVector3 rayPt2 = [self unprojectScreenCoords:GLKVector3Make(pos.x, pos.y, 1.0f)
                                         mvpInverse:&mvpInvMat
                                           viewport:&viewport];
    
    // transform the ray origin to object space for intersection test
//    GLKVector3 rayOrig = GLKVector3Add(rayPt1, arParent.arTranslationVec);
    
    GLKVector3 rayDir = GLKVector3Normalize(GLKVector3Subtract(rayPt2, rayPt1));
    
//    NSLog(@"CCSpriteAR: projected picking ray: %f, %f, %f", ray.x, ray.y, ray.z);
    
    return [self intersectionOfRayOrigin:&rayPt1 direction:&rayDir
                            sphereRadius:self.scale foundT:NULL];
}

#pragma mark private methods

-(GLKVector3)unprojectScreenCoords:(GLKVector3)screenPt
                        mvpInverse:(const GLKMatrix4 *)mvpInvMat
                          viewport:(const GLKVector4 *)viewport
{
    // taken from glm implementation
    
    GLKVector4 tmp = GLKVector4Make(screenPt.x, screenPt.y, screenPt.z, 1.0f);
    tmp.x = (tmp.x - viewport->v[0]) / viewport->v[2];
    tmp.y = (tmp.y - viewport->v[1]) / viewport->v[3];
    tmp = GLKVector4MultiplyScalar(tmp, 2.0f);
    tmp = GLKVector4AddScalar(tmp, -1.0f);
    
    tmp = GLKMatrix4MultiplyVector4(*mvpInvMat, tmp);
    
    return GLKVector3Make(tmp.x / tmp.w, tmp.y / tmp.w, tmp.z / tmp.w);
}

-(BOOL)intersectionOfRayOrigin:(const GLKVector3 *)o direction:(const GLKVector3 *)d
                  sphereRadius:(float)r foundT:(float *)t
{
    // taken from http://wiki.cgsociety.org/index.php/Ray_Sphere_Intersection
    
    // Compute A, B and C coefficients
    float a = GLKVector3DotProduct(*d, *d);
    float b = 2.0f * GLKVector3DotProduct(*d, *o);
    float c = GLKVector3DotProduct(*o, *o) - (r * r);
    
    // Find discriminant
    float disc = b * b - 4.0f * a * c;
    
    // if discriminant is negative there are no real roots, so return
    // false as ray misses sphere
    if (disc < 0) return NO;
    
    // compute q as described above
    float distSqrt = sqrtf(disc);
    float q;
    if (b < 0)
        q = (-b - distSqrt) / 2.0f;
    else
        q = (-b + distSqrt) / 2.0f;
    
    // compute t0 and t1
    float t0 = q / a;
    float t1 = c / q;
    
    // make sure t0 is smaller than t1
    if (t0 > t1) CC_SWAP(t0, t1);

    // if t1 is less than zero, the object is in the ray's negative direction
    // and consequently the ray misses the sphere
    if (t1 < 0.0f) return NO;
    
    // if t0 is less than zero, the intersection point is at t1
    if (t0 < 0.0f) {
        if (t) *t = t1;
        return YES;
    } else { // else the intersection point is at t0
        if (t) *t = t0;
        return NO;
    }
}

@end
