//
//  CCDirectorAR.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 22.07.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import "CCDirectorAR.h"

@implementation CCDirectorAR

-(void) setView:(CCGLView *)view
{
	if( view != __view) {
		[super setView:view];
        
		if( view ) {
			// set size
			CGFloat scale = view.contentScaleFactor;
			CGSize size = view.bounds.size;
			_winSizeInPixels = CGSizeMake(size.width * scale, size.height * scale);
		}
	}
}

@end
