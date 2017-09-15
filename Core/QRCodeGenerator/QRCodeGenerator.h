//
// QRCodeGenerator.h
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

#import <UIKit/UIKit.h>

/**
 Correction Level
 */
UIKIT_EXTERN NSString *const QRCodeCorrectionLevelLow;      // 7%
UIKIT_EXTERN NSString *const QRCodeCorrectionLevelMedium;   // 15%
UIKIT_EXTERN NSString *const QRCodeCorrectionLevelQuarter;  // 25%
UIKIT_EXTERN NSString *const QRCodeCorrectionLevelHigh;     // 30%

/**
 QRCodeGenerator
 */
@interface QRCodeGenerator : NSObject

/**
 Make QRCode image from data
 
 * @param data Source data
 * @return The QRCode image
 */
+ (UIImage *)imageWithData:(NSData *)data;

/**
 Make QRCode image from data
 
 * @param data Source data
 * @param size QRCode image size
 * @return The QRCode image
 */
+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size;

/**
 Make QRCode image from data
 
 * @param data Source data
 * @param size QRCode image size
 * @param color QRCode image tint color
 * @param backgroundColor QRCode background color
 * @return The QRCode image
 */
+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

/**
 Make QRCode image from data
 
 * @param data Source data
 * @param size QRCode image size
 * @param color QRCode image tint color
 * @param backgroundColor QRCode background color
 * @param correctionLevel with corresponding error resilience levels
 * @return The QRCode image
 */
+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor correctionLevel:(NSString *)correctionLevel;

/**
 Make QRCode image from text
 
 * @param text Source text string
 * @return The QRCode image
 */
+ (UIImage *)imageWithText:(NSString *)text;

/**
 Make QRCode image from text
 
 * @param text Source text string
 * @param size QRCode image size
 * @return The QRCode image
 */
+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size;

/**
 Make QRCode image from text
 
 * @param text Source text string
 * @param size QRCode image size
 * @param color QRCode image tint color
 * @param backgroundColor QRCode background color
 * @return The QRCode image
 */
+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

/**
 Make QRCode image from text
 
 * @param text Source text
 * @param size QRCode image size
 * @param color QRCode image tint color
 * @param backgroundColor QRCode background color
 * @param correctionLevel with corresponding error resilience levels
 * @return The QRCode image
 */
+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor correctionLevel:(NSString *)correctionLevel;

@end
