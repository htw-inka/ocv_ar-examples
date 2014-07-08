/*

File: PVRTexture.h
Abstract: The PVRTexture class is responsible for loading .pvr files.

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <Foundation/Foundation.h>

#import "Platforms/CCGL.h"
#import "CCTexture.h"

struct CCPVRMipmap {
	unsigned char *address;
	unsigned int len;
};

typedef struct _ccPVRTexturePixelFormatInfo {
	GLenum internalFormat;
	GLenum format;
	GLenum type;
	uint32_t bpp;
	BOOL compressed;
	BOOL alpha;
	CCTexturePixelFormat ccPixelFormat;
} ccPVRTexturePixelFormatInfo;

enum {
	CC_PVRMIPMAP_MAX = 16,
};

/** CCTexturePVR

 Object that loads PVR images.

 Supported PVR formats:
	- RGBA8888
	- BGRA8888
	- RGBA4444
	- RGBA5551
	- RGB565
	- A8
	- I8
	- AI88
	- PVRTC 4BPP
	- PVRTC 2BPP

 Limitations:
	Pre-generated mipmaps, such as PVR textures with mipmap levels embedded in file,
	are only supported if all individual sprites are of _square_ size.
	To use mipmaps with non-square textures, instead call CCTexture2D#generateMipmap on the sheet texture itself
	(and to save space, save the PVR sprite sheet without mip maps included).
 */
@interface CCTexturePVR : NSObject
{
    // Pointer to mipmap images.
	struct CCPVRMipmap	_mipmaps[CC_PVRMIPMAP_MAX];
    
    // Number of mipmap used.
	NSUInteger	_numberOfMipmaps;

    // Texture bits.
	uint32_t _width, _height;
	GLuint	_name;
	BOOL	_hasAlpha;
	BOOL	_hasPremultipliedAlpha;
	BOOL	_forcePremultipliedAlpha;

    // True to retain texture name.
	BOOL _retainName;
    
    // Texture pixel format used.
	CCTexturePixelFormat _format;
	
	const ccPVRTexturePixelFormatInfo *_pixelFormatInfo;
}


/// -----------------------------------------------------------------------
/// @name Creating a CCTexturePVR Object
/// -----------------------------------------------------------------------

/**
 *  Creates and returns a PVR Texture from the specified file path value.
 *
 *  @param path File path.
 *
 *  @return The CCTexturePVR object.
 */
+(id)pvrTextureWithContentsOfFile:(NSString *)path;

/**
 *  Creates and returns a PVR Texture from the specified URL value.
 *
 *  @param url Url object.
 *
 *  @return The CCTexturePVR object.
 */
+(id)pvrTextureWithContentsOfURL:(NSURL *)url;


/// -----------------------------------------------------------------------
/// @name Initializing a CCTexturePVR Object
/// -----------------------------------------------------------------------

/**
 *  Initializes a PVR Texture from the specified file path value.
 *
 *  @param path File path.
 *
 *  @return An initialized CCTexturePVR object.
 */
-(id)initWithContentsOfFile:(NSString *)path;

/**
 *  Initializes a PVR Texture from the specified URL value.
 *
 *  @param url Url object.
 *
 *  @return An initialized CCTexturePVR object.
 */
-(id)initWithContentsOfURL:(NSURL *)url;


/// -----------------------------------------------------------------------
/// @name Accessing PVR Texture Attributes
/// -----------------------------------------------------------------------

/** Texture id name. */
@property (nonatomic,readonly) GLuint name;

/** Texture width. */
@property (nonatomic,readonly) uint32_t width;

/** Texture height. */
@property (nonatomic,readonly) uint32_t height;

/** Whether or not the texture has alpha. */
@property (nonatomic,readonly) BOOL hasAlpha;

/** Whether or not the texture has premultiplied alpha. */
@property (nonatomic,readonly) BOOL hasPremultipliedAlpha;

/** Whether or not the texture should use hasPremultipliedAlpha instead of global default. */
@property (nonatomic,readonly) BOOL forcePremultipliedAlpha;

/** How many mipmaps the texture has. 1 means one level (level 0). */
@property (nonatomic, readonly) NSUInteger numberOfMipmaps;

/** True to retain texture name. */
@property (nonatomic,readwrite) BOOL retainName;

/** Texture pixel format used. */
@property (nonatomic,readonly) CCTexturePixelFormat format;

@end


