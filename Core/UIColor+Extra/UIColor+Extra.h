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
 Make color from integer with ARGB format.
 eg. 0xffffffff or 0xffffff or 0xff etc.
 
 @param value Color integer, ARGB format
 @return UIColor
 */
UIKIT_EXTERN UIColor * UIColorFromInteger(NSUInteger value);

/**
 Make color from RGBA value.

 @param r red, 0 - 255
 @param g green, 0 - 255
 @param b blue, 0 - 255
 @param a alpha, 0 - 255
 @return UIColor
 */
UIKIT_EXTERN UIColor * UIColorFromRGBA(uint8_t r, uint8_t g, uint8_t b, uint8_t a);

/**
 Make color from RGB value, alpha is 255.

 @param r red, 0 - 255
 @param g green, 0 - 255
 @param b blue, 0 - 255
 @return UIColor
 */
UIKIT_EXTERN UIColor * UIColorFromRGB(uint8_t r, uint8_t g, uint8_t b);

/**
 Make color from HEX string
 eg. @"ffffffff" or @"#ffffff" or @"0xffffffff" etc.
 
 @param string HEX string, ARGB format
 @return UIColor
 */
UIKIT_EXTERN UIColor * UIColorFromHexString(NSString *string);

/**
 Make HEX string from color.

 @param color UIColor
 @param alpha Whether or not have alpha field
 @return NSString
 */
UIKIT_EXTERN NSString * UIColorToHexString(UIColor *color, BOOL alpha);

/**
 Inverse color

 @param color Original color
 @return UIColor
 */
UIKIT_EXTERN UIColor * UIColorByInverse(UIColor *color);

/**
 UIColor Extra
 */
@interface UIColor (Extra)

/**
 Make color with HEX string

 @param string HEX string, ARGB format
 @return UIColor
 */
+ (instancetype)colorWithHexString:(NSString *)string;

/**
 Make color with HEX string and alpha

 @param string HEX string, RGB format
 @param alpha alpha value, 0.0 - 1.0
 @return UIColor
 */
+ (instancetype)colorWithHexString:(NSString *)string alpha:(CGFloat)alpha;

/**
 Gen random color

 @return UIColor
 */
+ (UIColor *)randomColor;

/**
 Return the HEX string of the color

 @return UIColor
 */
- (NSString *)hexString;

/**
 Return the inverse color

 @return UIColor
 */
- (UIColor *)inverseColor;

/**
 Return the alpha value of the color

 @return Alpha value
 */
- (CGFloat)alpha;

/**
 Return the red value of the color

 @return Red value
 */
- (CGFloat)red;

/**
 Return the green value of the color
 
 @return Green value
 */
- (CGFloat)green;

/**
 Return the blue value of the color
 
 @return Blue value
 */
- (CGFloat)blue;

/**
 Return the hue value of the color
 
 @return Hue value
 */
- (CGFloat)hue;

/**
 Return the saturation value of the color
 
 @return Saturation value
 */
- (CGFloat)saturation;

/**
 Return the brightness value of the color
 
 @return Brightness value
 */
- (CGFloat)brightness;

@end
