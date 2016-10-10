//
// QRCodeGenerator.h
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

@interface QRCodeGenerator : NSObject

/**
 * @brief Make QRCode image from data
 * @author xinyzhao[https://github.com/xinyzhao/ZXUtilityCode]
 * @param data Source data
 * @param size QRCode image size
 * @param color QRCode image tint color
 * @param backgroundColor QRCode background color
 * @return The QRCode image
 */
+ (UIImage *)imageWithData:(NSData *)data;
+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size;
+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

/**
 * @brief Make QRCode image from data
 * @author xinyzhao[https://github.com/xinyzhao/ZXUtilityCode]
 * @param text Source text string
 * @param size QRCode image size
 * @param color QRCode image tint color
 * @param backgroundColor QRCode background color
 * @return The QRCode image
 */
+ (UIImage *)imageWithText:(NSString *)text;
+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size;
+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

@end
