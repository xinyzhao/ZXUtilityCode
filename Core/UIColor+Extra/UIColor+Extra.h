//
// UIColor+Extra.h
//
// Copyright (c) 2016 Zhao Xin. All rights reserved.
//
// https://github.com/xinyzhao/ZXUtilityCode
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

/**
 * Make color from integer with ARGB format.
 * eg. 0xffffffff or 0xffffff or 0xff etc.
 */
UIKIT_EXTERN UIColor * UIColorFromInteger(NSUInteger value);
UIKIT_EXTERN UIColor * UIColorFromRGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
UIKIT_EXTERN UIColor * UIColorFromRGB(uint8_t r, uint8_t g, uint8_t b);

/**
 * Make color from HEX string with ARGB format.
 * eg. @"ffffffff" or @"#ffffff" or @"0xffffffff" etc.
 */
UIKIT_EXTERN UIColor * UIColorFromHexString(NSString *string);

/**
 * Make HEX string from color.
 */
UIKIT_EXTERN NSString * UIColorToHexString(UIColor *color, BOOL alpha);

/**
 * Make an inverse color.
 */
UIKIT_EXTERN UIColor * UIColorByInverse(UIColor *color);

/**
 * UIColor Extra
 */
@interface UIColor (Extra)

/* Make color from HEX string with ARGB format. */
+ (instancetype)colorWithHexString:(NSString *)string;
+ (instancetype)colorWithHexString:(NSString *)string alpha:(CGFloat)alpha;

/* Return the HEX string of the color. */
- (NSString *)hexString;

/* Return the inverse color. */
- (UIColor *)inverseColor;

/* Return the alpha value of the color. */
- (CGFloat)alpha;

/* Return the RGB components of the color. */
- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;

/* Return the HSB components of the color. */
- (CGFloat)hue;
- (CGFloat)saturation;
- (CGFloat)brightness;

@end
