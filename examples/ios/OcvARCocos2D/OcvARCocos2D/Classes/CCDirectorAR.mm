//
//  CCDirectorAR.m
//  OcvARCocos2D
//
//  Created by Markus Konrad on 22.07.14.
//  Copyright (c) 2014 INKA Research Group. All rights reserved.
//

#import "CCDirectorAR.h"

@implementation CCDirectorAR

//-(void)setBaseView:(UIView *)baseView glView:(CCGLView *)glView {
//    
//}

//-(void) setView:(CCGLView *)view
//{
//	if( view != __view) {
//        __view = view;
//        
//		if( view ) {
//            // set size
//            CGSize size = view.bounds.size;
//            CGFloat scale = __view.layer.contentsScale ?: 1.0;
//            _winSizeInPixels = CGSizeMake(size.width*scale, size.height*scale);
//            _winSizeInPoints = size;
//            __ccContentScaleFactor = scale;
//            
////			[super createStatsLabel];
//			[self setProjection: _projection];
//			
//			// TODO this should probably migrate somewhere else.
//			if(view.depthFormat){
//				glEnable(GL_DEPTH_TEST);
//				glDepthFunc(GL_LEQUAL);
//			}
//            
//            CC_CHECK_GL_ERROR_DEBUG();
//		}
//	}
//}

//-(void) setView:(CCGLView*)view
//{
//    //	NSAssert( view, @"OpenGLView must be non-nil");
//    
//	if( view != __view ) {
//        
//#ifdef __CC_PLATFORM_IOS
//		[super setView:view];
//#endif
//		__view = view;
//        
//		// set size
//		CGSize size = CCNSSizeToCGSize(__view.bounds.size);
//#ifdef __CC_PLATFORM_IOS
//		CGFloat scale = __view.layer.contentsScale ?: 1.0;
//#else
//		//self.view.wantsBestResolutionOpenGLSurface = YES;
//		CGFloat scale = self.view.window.backingScaleFactor;
//#endif
//		
//		_winSizeInPixels = CGSizeMake(size.width*scale, size.height*scale);
//		_winSizeInPoints = size;
//		__ccContentScaleFactor = scale;
//        
//		// it could be nil
//		if( view ) {
//			[self createStatsLabel];
//			[self setProjection: _projection];
//			
//			// TODO this should probably migrate somewhere else.
//			if(view.depthFormat){
//				glEnable(GL_DEPTH_TEST);
//				glDepthFunc(GL_LEQUAL);
//			}
//		}
//        
//		// Dump info once OpenGL was initilized
//		[[CCConfiguration sharedConfiguration] dumpInfo];
//        
//		CC_CHECK_GL_ERROR_DEBUG();
//	}
//}

//-(CCGLView*) view
//{
//	return  __view;
//}

@end
