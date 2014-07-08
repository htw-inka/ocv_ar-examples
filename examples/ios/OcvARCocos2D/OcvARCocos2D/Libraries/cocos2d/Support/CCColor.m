//
//  CCColor.m
//  cocos2d-ios
//
//  Created by Viktor on 12/10/13.
//
//

#import "CCColor.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation CCColor

+ (CCColor*) colorWithWhite:(float)white alpha:(float)alpha
{
    return [[CCColor alloc] initWithWhite:white alpha:alpha];
}

+ (CCColor*) colorWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (CCColor*) colorWithRed:(float)red green:(float)green blue:(float)blue
{
    return [[CCColor alloc] initWithRed:red green:green blue:blue];
}

+ (CCColor*) colorWithCGColor:(CGColorRef)cgColor
{
    return [[CCColor alloc] initWithCGColor:cgColor];
}

#ifdef __CC_PLATFORM_IOS
+ (CCColor*) colorWithUIColor:(UIColor *)color
{
    return [[CCColor alloc] initWithUIColor:color];
}
#endif

- (CCColor*) colorWithAlphaComponent:(float)alpha
{
    return [CCColor colorWithRed:_r green:_g blue:_b alpha:alpha];
}

- (CCColor*) initWithWhite:(float)white alpha:(float)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _r = white;
    _g = white;
    _b = white;
    _a = alpha;
    
    return self;
}

/** Hue in degrees 
 HSV-RGB Conversion adapted from code by Mr. Evil, beyondunreal wiki
 */
- (CCColor*) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness alpha:(float)alpha
{
	self = [super init];
	if (!self) return NULL;
	
	float chroma = saturation * brightness;
	float hueSection = hue / 60.0f;
	float X = chroma *  (1.0f - ABS(fmod(hueSection, 2.0f) - 1.0f));
	ccColor4F rgb = (ccColor4F){};

	if(hueSection < 1.0) {
		rgb.r = chroma;
		rgb.g = X;
	} else if(hueSection < 2.0) {
		rgb.r = X;
		rgb.g = chroma;
	} else if(hueSection < 3.0) {
		rgb.g = chroma;
		rgb.b = X;
	} else if(hueSection < 4.0) {
		rgb.g= X;
		rgb.b = chroma;
	} else if(hueSection < 5.0) {
		rgb.r = X;
		rgb.b = chroma;
	} else if(hueSection <= 6.0){
		rgb.r = chroma;
		rgb.b = X;
	}

	float Min = brightness - chroma;

	rgb.r += Min;
	rgb.g += Min;
	rgb.b += Min;
	rgb.a = alpha;

	return [CCColor colorWithCcColor4f:rgb];
}

- (CCColor*) initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha
{
    self = [super init];
    if (!self) return NULL;
    
    _r = red;
    _g = green;
    _b = blue;
    _a = alpha;
    
    return self;
}

- (CCColor*) initWithRed:(float)red green:(float)green blue:(float)blue
{
    self = [super init];
    if (!self) return NULL;
    
    _r = red;
    _g = green;
    _b = blue;
    _a = 1;
    
    return self;
}

- (CCColor*) initWithCGColor:(CGColorRef)cgColor
{
    self = [super init];
    if (!self) return NULL;
    
    const CGFloat *components = CGColorGetComponents(cgColor);
    
    _r = (float) components[0];
    _g = (float) components[1];
    _b = (float) components[2];
    _a = (float) components[3];
    
    return self;
}

#ifdef __CC_PLATFORM_IOS
- (CCColor*) initWithUIColor:(UIColor *)color
{
    self = [super init];
    if (!self) return self;
    
    CGColorRef colorRef = self.CGColor;
    CGColorSpaceModel csModel = CGColorSpaceGetModel(CGColorGetColorSpace(colorRef));
    if (csModel == kCGColorSpaceModelRGB)
    {
		    CGFloat r, g, b, a;
        [color getRed:&r green:&g blue:&b alpha:&a];
				_r = r, _g = g, _b = b, _a = a;
    }
    else if (csModel == kCGColorSpaceModelMonochrome)
    {
        CGFloat w, a;
        [color getWhite:&w alpha:&a];
        _r = w, _g = w, _b = w, _a = a;
    }
    else
    {
        NSAssert(NO, @"UIColor has unsupported color space model");
    }
    CGColorRelease(colorRef);
    
    return self;
}
#endif

/// After using you must call CGColorRelease(color)
- (CGColorRef) CGColor
{
    CGFloat components[4] = {(CGFloat)_r, (CGFloat)_g, (CGFloat)_b, (CGFloat)_a};
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGColorRef color = CGColorCreate(colorspace, components);
    CGColorSpaceRelease(colorspace);
    return color;
}

#ifdef __CC_PLATFORM_IOS

- (UIColor*) UIColor
{
    return [UIColor colorWithRed:_r green:_g blue:_b alpha:_a];
}

#endif

#ifdef __CC_PLATFORM_MAC
- (NSColor*) NSColor
{
	return [NSColor colorWithCalibratedRed:(CGFloat)_r green:(CGFloat)_g blue:(CGFloat)_b alpha:(CGFloat)_a];
}
#endif

- (BOOL) getRed:(float *)red green:(float *)green blue:(float *)blue alpha:(float *)alpha
{
    *red = _r;
    *green = _g;
    *blue = _b;
    *alpha = _a;
    
    return YES;
}

- (BOOL) getWhite:(float *)white alpha:(float *)alpha
{
    *white = (_r + _g + _b) / 3.0; // Just use an average of the components
    *alpha = _a;
    
    return YES;
}

- (CCColor*) interpolateTo:(CCColor *) toColor alpha:(float) t
{
	return [CCColor colorWithCcColor4f:ccc4FInterpolated(self.ccColor4f, toColor.ccColor4f, t)];
}

static CCColor *BLACK_COLOR = nil;
static CCColor *DARK_GRAY_COLOR = nil;
static CCColor *LIGHT_GRAY_COLOR = nil;
static CCColor *WHITE_COLOR = nil;
static CCColor *GRAY_COLOR = nil;
static CCColor *RED_COLOR = nil;
static CCColor *GREEN_COLOR = nil;
static CCColor *BLUE_COLOR = nil;
static CCColor *CYAN_COLOR = nil;
static CCColor *YELLOW_COLOR = nil;
static CCColor *MAGENTA_COLOR = nil;
static CCColor *ORANGE_COLOR = nil;
static CCColor *PURPLE_COLOR = nil;
static CCColor *BROWN_COLOR = nil;
static CCColor *CLEAR_COLOR = nil;

+(void)initialize
{
	BLACK_COLOR = [CCColor colorWithRed:0 green:0 blue:0 alpha:1];
	DARK_GRAY_COLOR = [CCColor colorWithWhite:1.0/3.0 alpha:1];
	LIGHT_GRAY_COLOR = [CCColor colorWithWhite:2.0/3.0 alpha:1];
	WHITE_COLOR = [CCColor colorWithWhite:1 alpha:1];
	GRAY_COLOR = [CCColor colorWithWhite:0.5 alpha:1];
	RED_COLOR = [CCColor colorWithRed:1 green:0 blue:0 alpha:1];
	GREEN_COLOR = [CCColor colorWithRed:0 green:1 blue:0 alpha:1];
	BLUE_COLOR = [CCColor colorWithRed:0 green:0 blue:1 alpha:1];
	CYAN_COLOR = [CCColor colorWithRed:0 green:1 blue:1 alpha:1];
	YELLOW_COLOR = [CCColor colorWithRed:1 green:1 blue:0 alpha:1];
	MAGENTA_COLOR = [CCColor colorWithRed:1 green:0 blue:1 alpha:1];
	ORANGE_COLOR = [CCColor colorWithRed:1 green:0.5 blue:0 alpha:1];
	PURPLE_COLOR = [CCColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
	BROWN_COLOR = [CCColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1];
	CLEAR_COLOR = [CCColor colorWithRed:0 green:0 blue:0 alpha:0];
}

+ (CCColor*) blackColor {return BLACK_COLOR;}
+ (CCColor*) darkGrayColor {return DARK_GRAY_COLOR;}
+ (CCColor*) lightGrayColor {return LIGHT_GRAY_COLOR;}
+ (CCColor*) whiteColor {return WHITE_COLOR;}
+ (CCColor*) grayColor {return GRAY_COLOR;}
+ (CCColor*) redColor {return RED_COLOR;}
+ (CCColor*) greenColor {return GREEN_COLOR;}
+ (CCColor*) blueColor {return BLUE_COLOR;}
+ (CCColor*) cyanColor {return CYAN_COLOR;}
+ (CCColor*) yellowColor {return YELLOW_COLOR;}
+ (CCColor*) magentaColor {return MAGENTA_COLOR;}
+ (CCColor*) orangeColor {return ORANGE_COLOR;}
+ (CCColor*) purpleColor {return PURPLE_COLOR;}
+ (CCColor*) brownColor {return BROWN_COLOR;}
+ (CCColor*) clearColor {return CLEAR_COLOR;}

@end


@implementation CCColor (OpenGL)

+ (CCColor*) colorWithCcColor3b:(ccColor3B)c
{
    return [[CCColor alloc] initWithCcColor3b:c];
}

+ (CCColor*) colorWithCcColor4b:(ccColor4B)c
{
    return [[CCColor alloc] initWithCcColor4b:c];
}

+ (CCColor*) colorWithCcColor4f:(ccColor4F)c
{
    return [[CCColor alloc] initWithCcColor4f:c];
}

+ (CCColor*) colorWithGLKVector4:(GLKVector4)c
{
    return [[CCColor alloc] initWithGLKVector4:c];
}

- (CCColor*) initWithCcColor3b: (ccColor3B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:1];
}

- (CCColor*) initWithCcColor4b: (ccColor4B) c
{
    return [self initWithRed:c.r/255.0 green:c.g/255.0 blue:c.b/255.0 alpha:c.a/255.0];
}

- (CCColor*) initWithCcColor4f: (ccColor4F) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (CCColor*) initWithGLKVector4: (GLKVector4) c
{
    return [self initWithRed:c.r green:c.g blue:c.b alpha:c.a];
}

- (ccColor3B) ccColor3b
{
    return (ccColor3B){(GLubyte)(_r*255), (GLubyte)(_g*255), (GLubyte)(_b*255)};
}

- (ccColor4B) ccColor4b
{
    return (ccColor4B){(GLubyte)(_r*255), (GLubyte)(_g*255), (GLubyte)(_b*255), (GLubyte)(_a*255)};
}

- (ccColor4F) ccColor4f
{
    return ccc4f(_r, _g, _b, _a);
}

-(GLKVector4)glkVector4
{
	return GLKVector4Make(_r, _g, _b, _a);
}

@end

@implementation CCColor (ExtraProperties)

- (float) red
{
    return _r;
}

- (float) green
{
    return _g;
}

- (float) blue
{
    return _b;
}

- (float) alpha
{
    return _a;
}

- (BOOL) isEqual:(id)color
{
    if (self == color) return YES;
    if (![color isKindOfClass:[CCColor class]]) return NO;
    
    ccColor4F c4f0 = self.ccColor4f;
    ccColor4F c4f1 = ((CCColor*)color).ccColor4f;
    
    return ccc4FEqual(c4f0, c4f1);
}

- (BOOL) isEqualToColor:(CCColor*) color
{
    return [self isEqual:color];
}

@end
