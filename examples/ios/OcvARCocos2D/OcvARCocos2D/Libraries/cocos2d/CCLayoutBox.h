/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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
 */

#import "CCLayout.h"

/**
 *  Declares the possible directions for laying out nodes in a CCLayoutBox.
 */
typedef NS_ENUM(NSUInteger, CCLayoutBoxDirection)
{
    /// The children will be layout out in a horizontal line.
    CCLayoutBoxDirectionHorizontal,
    
    /// The children will be layout out in a vertical line.
    CCLayoutBoxDirectionVertical,
};

/**
 *  The box layout lays out its children in a horizontal or vertical row. Optionally you can set a spacing between the child nodes.
 */
@interface CCLayoutBox : CCLayout

/**
 *  The direction is either horizontal or vertical.
 */
@property (nonatomic,assign) CCLayoutBoxDirection direction;

/**
 *  The spacing in points between the child nodes.
 */
@property (nonatomic,assign) float spacing;

@end
