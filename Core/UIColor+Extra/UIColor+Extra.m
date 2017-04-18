//
// UIColor+Extra.m
//
// Copyright (c) 2016-2017 Zhao Xin (https://github.com/xinyzhao/ZXUtilityCode)
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

#import "UIColor+Extra.h"

UIColor* UIColorFromRGBA(CGFloat r, CGFloat g, CGFloat b, CGFloat a) {
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

UIColor* UIColorFromRGB(CGFloat r, CGFloat g, CGFloat b) {
    return UIColorFromRGBA(r, g, b, 1.f);
}

UIColor* UIColorFromHEX(NSUInteger value, CGFloat alpha) {
    CGFloat r = ((value & 0x00ff0000) >> 16) / 255.f;
    CGFloat g = ((value & 0x0000ff00) >> 8) / 255.f;
    CGFloat b = (value & 0x000000ff) / 255.f;
    return UIColorFromRGBA(r, g, b, alpha);
}

UIColor* UIColorFromHexString(NSString *string, CGFloat alpha) {
    NSRange range = [string rangeOfString:@"[a-fA-F0-9]{6,8}" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        unsigned int hex = 0;
        NSString *str = [string substringWithRange:range];
        [[NSScanner scannerWithString:str] scanHexInt:&hex];
        return UIColorFromHEX(hex, alpha);
    }
    return nil;
}

NSString* UIColorToHexString(UIColor *color) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"%02x%02x%02x",
            (int)roundf(r * 255),
            (int)roundf(g * 255),
            (int)roundf(b * 255)];
}

UIColor* UIColorByInverse(UIColor *color) {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:1.f - r green:1.f - g blue:1.f - b alpha:a];
}

@implementation UIColor (Extra)

+ (instancetype)colorWithHexString:(NSString *)string {
    return UIColorFromHexString(string, 1.f);
}

+ (instancetype)colorWithHexString:(NSString *)string alpha:(CGFloat)alpha {
    return UIColorFromHexString(string, alpha);
}

+ (UIColor *)randomColor {
    CGFloat r = (arc4random() % 256) / 255.f;
    CGFloat g = (arc4random() % 256) / 255.f;
    CGFloat b = (arc4random() % 256) / 255.f;
    return UIColorFromRGB(r, g, b);
}

- (NSString *)hexString {
    return UIColorToHexString(self);
}

- (UIColor *)inverseColor {
    return UIColorByInverse(self);
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

- (CGFloat)red {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return r;
}

- (CGFloat)green {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return g;
}

- (CGFloat)blue {
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return b;
}

- (CGFloat)hue {
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return h;
}

- (CGFloat)saturation {
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return s;
}

- (CGFloat)brightness {
    CGFloat h,s,b,a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return b;
}

@end
