/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2009 Jason Booth
 * Copyright (c) 2013 Nader Eloshaiker
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

#import "CCActionInterval.h"

#pragma mark - Ease Actions
/**
 *  CCActionEase adds the ability to modify existing actions to create more realistic effects.
 */
@interface CCActionEase : CCActionInterval <NSCopying> {
	CCActionInterval *_inner;
}

// The inner action.
@property (nonatomic, readonly) CCActionInterval *inner;

/**
 *  Creates a new basic ease action.
 *
 *  @param action Interval action.
 *
 *  @return New ease action.
 */
+ (id)actionWithAction:(CCActionInterval*)action;

/**
 *  Initializes a new basic ease action.
 *
 *  @param action Interval action.
 *
 *  @return New ease action.
 */
- (id)initWithAction:(CCActionInterval*)action;

@end


#pragma mark - Ease Sine Actions
/**
 *  This action will start the specified action with an sine effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseSineIn : CCActionEase <NSCopying>
@end

/**
 *  This action will start the specified action with an sine effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseSineOut : CCActionEase <NSCopying>
@end

/**
 *  This action will start the specified action with an sine effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseSineInOut : CCActionEase <NSCopying>
@end

/**
 *  This action will start the specified action with a reversed acceleration.
 *
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBackIn : CCActionEase <NSCopying>

@end


/**
 *  This action will end the specified action with a reversed acceleration.
 *
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBackOut : CCActionEase <NSCopying>

@end


/**
 *  This action will start and end the specified action with a reversed acceleration.
 *
 *  Note:
 *  This action doesn't use a bijective function. Actions like Sequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBackInOut : CCActionEase <NSCopying>

@end


#pragma mark - Ease Rate Actions
/** 
 *  CCActionEaseRate adds an additional rate property to control the rate of change for the specified action.
 */
@interface CCActionEaseRate :  CCActionEase <NSCopying> {
	float	_rate;
}

/** Rate value for the ease action. */
@property (nonatomic,readwrite,assign) float rate;

/**
 *  Creates the action with the inner action and the rate parameter.
 *
 *  @param action Interval action to ease.
 *  @param rate   Action rate.
 *
 *  @return New rate action.
 */
+ (id)actionWithAction:(CCActionInterval*)action rate:(float)rate;

/**
 *  Initializes the action with the inner action and the rate parameter.
 *
 *  @param action Interval action to ease.
 *  @param rate   Action rate.
 *
 *  @return New rate action.
 */
- (id)initWithAction:(CCActionInterval*)action rate:(float)rate;

@end


/** 
 *  This action will accelerate the specified action by the rate.
 */
@interface CCActionEaseIn : CCActionEaseRate <NSCopying>

@end


/**
 *  This action will deccelerate the specified action by the rate.
 */
@interface CCActionEaseOut : CCActionEaseRate <NSCopying>

@end


/**
 *  This action will both accelerate and deccelerate the specified action with same rate.
 */
@interface CCActionEaseInOut : CCActionEaseRate <NSCopying>

@end


/**
 *  CCActionEaseElastic adds a period property and applies a dampened oscillation to the specified action.
 */
@interface CCActionEaseElastic : CCActionEase <NSCopying> {
	float _period;
}

/** Period of the wave in radians. Default is 0.3. */
@property (nonatomic,readwrite) float period;

/**
 *  Creates the action with the inner action and the period in radians (default is 0.3).
 *
 *  @param action Action to apply ease action to.
 *  @param period eriod of wave in radians.
 *
 *  @return New elastic action.
 */
+ (id)actionWithAction:(CCActionInterval*)action period:(float)period;

/**
 *  Initializes the action with the inner action and the period in radians (default is 0.3).
 *
 *  @param action Action to apply ease action to.
 *  @param period eriod of wave in radians.
 *
 *  @return New elastic action.
 */
- (id)initWithAction:(CCActionInterval*)action period:(float)period;

@end


#pragma mark - Elastic Actions
/**
 *  This action will start the specified action with an elastic effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseElasticIn : CCActionEaseElastic <NSCopying>

@end


/**
 *  This action will end the specified action with an elastic effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseElasticOut : CCActionEaseElastic <NSCopying>

@end


/**
 *  This action will start and end the specified action with an elastic effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseElasticInOut : CCActionEaseElastic <NSCopying>

@end


#pragma mark - Ease Bounce Actions
/**
 *  CCActionEaseBounce adds a bounceTime property and applies a bouncing effect to the specified action.
 */
@interface CCActionEaseBounce : CCActionEase <NSCopying>

// Bounce time.
- (CCTime)bounceTime:(CCTime)t;

@end


/**
 *  This action will start the specified action with a bounce effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBounceIn : CCActionEaseBounce <NSCopying>

@end


/**
 *  This action will end the specified action with a bounce effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBounceOut : CCActionEaseBounce <NSCopying>

@end


/**
 *  This action will start and end the specified action with a bounce effect.
 *
 *  Note: This action doesn't use a bijective function, actions like CCActionSequence might have an unexpected result when used with this action.
 */
@interface CCActionEaseBounceInOut : CCActionEaseBounce <NSCopying>

@end

// SpriteBuilder Support Ease
@interface CCActionEaseInstant : CCActionEase <NSCopying>

@end


