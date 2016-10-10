//
// QRCodeGenerator.m
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

#import "QRCodeGenerator.h"

#define QRCodeForegroundColor [UIColor blackColor]
#define QRCodeBackgroundColor [UIColor whiteColor]

@implementation QRCodeGenerator

+ (UIImage *)imageWithData:(NSData *)data {
    return [QRCodeGenerator imageWithData:data size:CGSizeZero];
}

+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size {
    return [QRCodeGenerator imageWithData:data size:size color:nil backgroundColor:nil];
}

+ (UIImage *)imageWithData:(NSData *)data size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    if (data.length > 0) {
        // 生成
        CIFilter *qrcodeFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrcodeFilter setValue:data forKey:@"inputMessage"];
        [qrcodeFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        // 上色
        CIImage *colorImage = qrcodeFilter.outputImage;
        if (color || backgroundColor) {
            if (color == nil) {
                color = QRCodeForegroundColor;
            }
            if (backgroundColor == nil) {
                backgroundColor = QRCodeBackgroundColor;
            }
            CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                               keysAndValues:
                                     @"inputImage", colorImage,
                                     @"inputColor0", [CIColor colorWithCGColor:color.CGColor],
                                     @"inputColor1", [CIColor colorWithCGColor:backgroundColor.CGColor],
                                     nil];
            colorImage = colorFilter.outputImage;
        }
        // 绘制
        if (CGSizeEqualToSize(CGSizeZero, size)) {
            size = colorImage.extent.size;
            size.width -= colorImage.extent.origin.x;
            size.height -= colorImage.extent.origin.y;
        }
        CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:colorImage fromRect:colorImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        CGContextDrawImage(contextRef, CGContextGetClipBoundingBox(contextRef), imageRef);
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(imageRef);
        //
        return finalImage;
    }
    return nil;
}

+ (UIImage *)imageWithText:(NSString *)text {
    return [QRCodeGenerator imageWithText:text size:CGSizeZero];
}

+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size {
    return [QRCodeGenerator imageWithText:text size:size color:nil backgroundColor:nil];
}

+ (UIImage *)imageWithText:(NSString *)text size:(CGSize)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    return [QRCodeGenerator imageWithData:data size:size color:color backgroundColor:backgroundColor];
}

@end
