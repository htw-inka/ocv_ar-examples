/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Matt Oswald
 * Copyright (c) 2009-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2011 Marco Tillemans
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 *
 */

#import "CCNode.h"

@class CCTextureAtlas;
@class CCParticleSystemBase;

/** 
 CCParticleBatchNode offers improved performance by operating in the same manner as CCSpriteBatchNode by rendering all particles systems as a batch (1 OpenGL Call).
 
 ### Limitations
 
 - Only CCParticleSystem is supported.
 - All particle systems need to be drawn with the same parameters, blend function, aliasing and texture.
 
 ### Notes
 
 - Initialize the ParticleBatchNode with the texture and enough capacity for all the required particle systems.
 - Initialize all particle systems and add them as child to the CCParticleBatchNode.
 - Default capacity is 500.

 */
__attribute__((deprecated))
@interface CCParticleBatchNode : CCNode<CCTextureProtocol, CCShaderProtocol, CCBlendProtocol>


/// -----------------------------------------------------------------------
/// @name Creating a CCParticleBatchNode Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a particle batch node object from the specified texture value.
 *
 *  @param tex  Texture.
 *
 *  @return The CCParticleBatchNode Object.
 */
+(id)batchNodeWithTexture:(CCTexture *)tex;

/**
 *  Creates and returns a particle batch node object from the specified image file value.
 *
 *  @param imageFile Image file path.
 *
 *  @return The CCParticleBatchNode Object.
 */
+(id)batchNodeWithFile:(NSString*) imageFile;

/**
 *  Creates and returns a particle batch node object from the specified texture and capacity values.
 *
 *  @param tex      Texture.
 *  @param capacity Initial capacity.
 *
 *  @return The CCParticleBatchNode Object.
 */
+(id)batchNodeWithTexture:(CCTexture *)tex capacity:(NSUInteger) capacity;

/**
 *  Creates and returns a particle batch node object from the specified texture and capacity values.
 *
 *  @param fileImage Image file path.
 *  @param capacity  Initial capacity.
 *
 *  @return The CCParticleBatchNode Object.
 */

+(id)batchNodeWithFile:(NSString*)fileImage capacity:(NSUInteger)capacity;


/// -----------------------------------------------------------------------
/// @name Initializing a CCParticleBatchNode Object
/// -----------------------------------------------------------------------

/**
 *  Initializes and returns a particle batch node object from the specified texture and capacity values.
 *
 *  @param tex      Texture.
 *  @param capacity Initial capacity.
 *
 *  @return An initialized CCParticleBatchNode Object.
 */
-(id)initWithTexture:(CCTexture *)tex capacity:(NSUInteger)capacity;

/**
 *  Initializes and returns a particle batch node object from the specified texture and capacity values.
 *
 *  @param fileImage Image file path.
 *  @param capacity Initial capacity.
 *
 *  @return An initialized CCParticleBatchNode Object.
 */
-(id)initWithFile:(NSString *)fileImage capacity:(NSUInteger)capacity;

@end
