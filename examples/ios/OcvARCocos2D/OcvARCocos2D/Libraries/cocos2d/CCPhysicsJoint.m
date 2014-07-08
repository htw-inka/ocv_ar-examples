/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Scott Lembcke
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCPhysicsJoint.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "CCNode_Private.h"

@interface CCNode(Private)
-(CGAffineTransform)nonRigidTransform;
@end



@interface CCPhysicsPivotJoint : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchor:(CGPoint)anchor;
@end

@interface CCPhysicsPinJoint : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB;
@end

@interface CCPhysicsSlideJoint : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB minDistance:(CGFloat)min maxDistance:(CGFloat)max;
@end

@interface CCPhysicsSpringJoint : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping;
@end

@interface CCPhysicsRotarySpring : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB restAngle:(cpFloat)restAngle stifness:(cpFloat)stiffness damping:(cpFloat)damping;
@end

@interface CCPhysicsMotorJoint : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB rate:(cpFloat)rate;
@end

@interface CCPhysicsRatchet : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB phase:(cpFloat)phase ratchet:(cpFloat)ratchet;
@end

@interface CCPhysicsRotaryLimitJoint : CCPhysicsJoint
-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB min:(cpFloat)min max:(cpFloat)max;
@end

@implementation CCPhysicsJoint
{
@protected
	float scale;
}


-(id)init
{
	if((self = [super init])){
		_valid = YES;
		scale = 0.0f;//Uninitialized.
	}
	
	return self;
}

-(void)addToPhysicsNode:(CCPhysicsNode *)physicsNode
{
	NSAssert(self.bodyA.physicsNode == self.bodyB.physicsNode, @"Bodies connected by a joint must be added to the same CCPhysicsNode.");
	
	[self willAddToPhysicsNode:physicsNode];
	[physicsNode.space smartAdd:self];
}

+(CCPhysicsJoint *)connectedPivotJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA
{
	CCPhysicsJoint *joint = [[CCPhysicsPivotJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchor:anchorA];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
										   anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
{
	CCPhysicsJoint *joint = [[CCPhysicsPinJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchorA:anchorA anchorB:anchorB];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

+(CCPhysicsJoint *)connectedDistanceJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
										   anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
									   minDistance:(CGFloat)min maxDistance:(CGFloat)max
{
	CCPhysicsJoint *joint = [[CCPhysicsSlideJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchorA:anchorA anchorB:anchorB minDistance:min maxDistance:max];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	return joint;
}

+(CCPhysicsJoint *)connectedSpringJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
										 anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
									  restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping
{
	CCPhysicsSpringJoint *joint = [[CCPhysicsSpringJoint alloc] initWithBodyA:bodyA bodyB:bodyB anchorA:anchorA anchorB:anchorB restLength:restLength stiffness:stiffness damping:damping];
	[bodyA addJoint:joint];
	[bodyB addJoint:joint];
	
	[joint addToPhysicsNode:bodyA.physicsNode];
	
	
	return joint;
}



+(CCPhysicsJoint *)connectedRotarySpringJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
                                       restAngle:(CGFloat)restAngle
                                        stifness:(CGFloat)stiffness
                                         damping:(CGFloat)damping
{
    CCPhysicsRotarySpring * joint  = [[CCPhysicsRotarySpring alloc] initWithBodyA:bodyA bodyB:bodyB restAngle:restAngle stifness:stiffness damping:damping];
    
    [bodyA addJoint:joint];
	[bodyB addJoint:joint];
    [joint addToPhysicsNode:bodyA.physicsNode];
    return joint;
}


+(CCPhysicsJoint *)connectedMotorJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
                                             rate:(CGFloat)rate
{
    CCPhysicsMotorJoint * joint  = [[CCPhysicsMotorJoint alloc] initWithBodyA:bodyA bodyB:bodyB rate:rate];
    
    [bodyA addJoint:joint];
	[bodyB addJoint:joint];
    [joint addToPhysicsNode:bodyA.physicsNode];
    return joint;
}



+(CCPhysicsJoint *)connectedRotaryLimitJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
                                            min:(cpFloat)min
                                            max:(cpFloat)max
{
    CCPhysicsRotaryLimitJoint * joint  = [[CCPhysicsRotaryLimitJoint alloc] initWithBodyA:bodyA bodyB:bodyB min:min max:max];
    
    [bodyA addJoint:joint];
	[bodyB addJoint:joint];
    [joint addToPhysicsNode:bodyA.physicsNode];
    return joint;
}


+(CCPhysicsJoint *)connectedRatchetJointWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB
                                                  phase:(cpFloat)phase
                                                  ratchet:(cpFloat)ratchet
{
    CCPhysicsRatchet * joint  = [[CCPhysicsRatchet alloc] initWithBodyA:bodyA bodyB:bodyB phase:phase ratchet:ratchet];
    
    [bodyA addJoint:joint];
	[bodyB addJoint:joint];
    [joint addToPhysicsNode:bodyA.physicsNode];
    return joint;
}



-(CCPhysicsBody *)bodyA {return self.constraint.bodyA.userData;}
//-(void)setBodyA:(CCPhysicsBody *)bodyA {NYI();}

-(CCPhysicsBody *)bodyB {return self.constraint.bodyB.userData;}
//-(void)setBodyB:(CCPhysicsBody *)bodyB {NYI();}

-(CGFloat)maxForce {return self.constraint.maxForce;}

-(void)setMaxForce:(CGFloat)maxForce
{
	NSAssert(maxForce > 0.0, @"Max force must be greater than 0.");
	self.constraint.maxForce = maxForce;
}

-(CGFloat)impulse {return self.constraint.impulse;}

-(BOOL)collideBodies
{
    return self.constraint.collideBodies;
}

-(void)setCollideBodies:(BOOL)collideBodies
{
    self.constraint.collideBodies = collideBodies;
}
-(void)invalidate {
	_valid = NO;
	
	[self tryRemoveFromPhysicsNode:self.bodyA.physicsNode];
	[self.bodyA removeJoint:self];
	[self.bodyB removeJoint:self];
}

static void
BreakConstraint(cpConstraint *constraint, cpSpace *space)
{
	CCPhysicsJoint *joint = [[ChipmunkConstraint constraintFromCPConstraint:constraint] userData];
	
	// Divide by the timestep to convent the impulse to a force.
	if(cpConstraintGetImpulse(constraint)/cpSpaceGetCurrentTimeStep(space) > joint.breakingForce){
		[joint invalidate];
	}
}

-(void)setBreakingForce:(CGFloat)breakingForce
{
	NSAssert(breakingForce > 0.0, @"Breaking force must be greater than 0.");
	_breakingForce = breakingForce;
	cpConstraintSetPostSolveFunc(self.constraint.constraint, breakingForce < INFINITY ? BreakConstraint : NULL);
}

@end


@implementation CCPhysicsPivotJoint {
	ChipmunkPivotJoint *_constraint;
	CGPoint _anchor;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchor:(CGPoint)anchor
{
	if((self = [super init])){
		_constraint = [ChipmunkPivotJoint pivotJointWithBodyA:bodyA.body bodyB:bodyB.body pivot:CCP_TO_CPV(anchor)];
		_constraint.userData = self;
		
		_anchor = anchor;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	
	CCPhysicsBody *bodyA = self.bodyA;
	CGPoint anchor = CGPointApplyAffineTransform(_anchor, bodyA.node.nonRigidTransform);
	
	_constraint.anchorA = CCP_TO_CPV(anchor);
	_constraint.anchorB = [_constraint.bodyB worldToLocal:[_constraint.bodyA localToWorld:CCP_TO_CPV(anchor)]];
}

@end




@implementation CCPhysicsRotarySpring{
	ChipmunkDampedRotarySpring *_constraint;
    float restAngle;

}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB restAngle:(cpFloat)_restAngle stifness:(cpFloat)stiffness damping:(cpFloat)damping
{
	if((self = [super init])){
		_constraint = [ChipmunkDampedRotarySpring dampedRotarySpringWithBodyA:bodyA.body bodyB:bodyB.body restAngle:_restAngle stiffness:stiffness damping:damping];
		_constraint.userData = self;
        _constraint.restAngle = _restAngle;
        restAngle = _restAngle;
		
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	float currentAngle = (_constraint.bodyA.angle - _constraint.bodyB.angle);
    
    _constraint.restAngle = currentAngle + restAngle;
}

@end


@implementation CCPhysicsPinJoint {
	ChipmunkPinJoint *_constraint;
	CGPoint _anchorA, _anchorB;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB
{
	if((self = [super init])){
		_constraint = [ChipmunkPinJoint pinJointWithBodyA:bodyA.body bodyB:bodyB.body anchorA:CCP_TO_CPV(anchorA) anchorB:CCP_TO_CPV(anchorB)];
		_constraint.userData = self;
		
		_anchorA = anchorA;
		_anchorB = anchorB;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	CGPoint anchorA = CGPointApplyAffineTransform(_anchorA, bodyA.node.nonRigidTransform);
	CGPoint anchorB = CGPointApplyAffineTransform(_anchorB, bodyB.node.nonRigidTransform);
    _constraint.anchorA = CCP_TO_CPV(anchorA);
    _constraint.anchorB = CCP_TO_CPV(anchorB);
	
	_constraint.anchorA = CCP_TO_CPV(anchorA);
	_constraint.anchorB = CCP_TO_CPV(anchorB);
	_constraint.dist = cpvdist([bodyA.body localToWorld:CCP_TO_CPV(anchorA)], [bodyB.body localToWorld:CCP_TO_CPV(anchorB)]);
}

@end




@implementation CCPhysicsSlideJoint {
	ChipmunkSlideJoint *_constraint;
	CGPoint _anchorA, _anchorB;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB minDistance:(CGFloat)min maxDistance:(CGFloat)max
{
	if((self = [super init])){
		_constraint = [ChipmunkSlideJoint slideJointWithBodyA:bodyA.body bodyB:bodyB.body anchorA:CCP_TO_CPV(anchorA) anchorB:CCP_TO_CPV(anchorB) min:min max:max];
		_constraint.userData = self;
		
		_anchorA = anchorA;
		_anchorB = anchorB;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	_constraint.anchorA = CCP_TO_CPV(CGPointApplyAffineTransform(_anchorA, bodyA.node.nonRigidTransform));
	_constraint.anchorB = CCP_TO_CPV(CGPointApplyAffineTransform(_anchorB, bodyB.node.nonRigidTransform));
}

-(void)setScale:(float)_scale
{
	if(scale != 0.0f &&  _scale != scale)
	{
		float ratioChange = _scale/scale;
		_constraint.min = _constraint.min * ratioChange;
		_constraint.max = _constraint.max * ratioChange;
	}
	[super setScale:_scale];
}


@end



@implementation CCPhysicsSpringJoint {
	ChipmunkDampedSpring *_constraint;
	CGPoint _anchorA, _anchorB;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB anchorA:(CGPoint)anchorA anchorB:(CGPoint)anchorB restLength:(CGFloat)restLength stiffness:(CGFloat)stiffness damping:(CGFloat)damping

{
	if((self = [super init])){
		_constraint = [ChipmunkDampedSpring dampedSpringWithBodyA:bodyA.body bodyB:bodyB.body anchorA:CCP_TO_CPV(anchorA) anchorB:CCP_TO_CPV(anchorB) restLength:restLength stiffness:stiffness damping:damping];
		_constraint.userData = self;
		
		_anchorA = anchorA;
		_anchorB = anchorB;
	}
	
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	CCPhysicsBody *bodyA = self.bodyA, *bodyB = self.bodyB;
	_constraint.anchorA = CCP_TO_CPV(CGPointApplyAffineTransform(_anchorA, bodyA.node.nonRigidTransform));
	_constraint.anchorB = CCP_TO_CPV(CGPointApplyAffineTransform(_anchorB, bodyB.node.nonRigidTransform));
	
}

-(void)setScale:(float)_scale
{
	if(scale != 0.0f && _scale != scale)
	{
		float ratioChange = _scale/scale;
		_constraint.restLength = _constraint.restLength * ratioChange;
	}
	[super setScale:_scale];
}

@end

@implementation CCPhysicsMotorJoint
{
	ChipmunkSimpleMotor *_constraint;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB rate:(cpFloat)rate
{
    if((self = [super init])){
        _constraint = [ChipmunkSimpleMotor simpleMotorWithBodyA:bodyA.body bodyB:bodyB.body rate:rate];
		_constraint.userData = self;
    }
    
	return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	
}

@end

@implementation CCPhysicsRatchet
{
    ChipmunkRatchetJoint * _constraint;
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB phase:(cpFloat)phase ratchet:(cpFloat)ratchet
{
    if((self = [super init])){
        _constraint = [ChipmunkRatchetJoint ratchetJointWithBodyA:bodyA.body bodyB:bodyB.body phase:phase ratchet:ratchet];
        _constraint.userData = self;
    }
    
    return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	
}


@end

@implementation CCPhysicsRotaryLimitJoint
{
    ChipmunkRotaryLimitJoint * _constraint;
    float min;
    float max;
    
}

-(id)initWithBodyA:(CCPhysicsBody *)bodyA bodyB:(CCPhysicsBody *)bodyB min:(cpFloat)_min max:(cpFloat)_max
{
    if((self = [super init])){
        _constraint = [ChipmunkRotaryLimitJoint rotaryLimitJointWithBodyA:bodyA.body bodyB:bodyB.body min:_min max:_max];
        min = _min;
        max = _max;
    }
    
    return self;
}

-(ChipmunkConstraint *)constraint {return _constraint;}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
    float currentAngle = (_constraint.bodyB.angle - _constraint.bodyA.angle);
    
    _constraint.max = currentAngle - min;
    _constraint.min = currentAngle - max;
}



@end



@implementation CCPhysicsJoint(ObjectiveChipmunk)

-(id<NSFastEnumeration>)chipmunkObjects {return [NSArray arrayWithObject:self.constraint];}

-(ChipmunkConstraint *)constraint
{
	@throw [NSException exceptionWithName:@"AbstractInvocation" reason:@"This method is abstract." userInfo:nil];
}

-(BOOL)isRunning
{
	return (self.bodyA.isRunning && self.bodyB.isRunning);
}

-(void)tryAddToPhysicsNode:(CCPhysicsNode *)physicsNode
{
	if(self.isRunning && self.constraint.space == nil)
	{
		self.scale = NodeToPhysicsScale(self.bodyA.node).x;//We only care about uniform scaling.
		[self addToPhysicsNode:physicsNode];
	}
}

-(void)tryRemoveFromPhysicsNode:(CCPhysicsNode *)physicsNode
{
	if(self.constraint.space) [physicsNode.space smartRemove:self];
}

-(void)willAddToPhysicsNode:(CCPhysicsNode *)physics
{
	@throw [NSException exceptionWithName:@"AbstractInvocation" reason:@"This method is abstract." userInfo:nil];
}

-(float)scale
{
	return scale;
}

-(void)setScale:(float)_scale
{
	scale = _scale;
}

-(void)resetScale:(float)_scale
{
	scale = _scale;
}

@end
