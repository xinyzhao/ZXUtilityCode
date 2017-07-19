//
// UIImage+Extra.h
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
#import <ImageIO/ImageIO.h>
#import <CoreGraphics/CoreGraphics.h>

/// 压缩
UIKIT_EXTERN NSData *UIImageCompressToData(UIImage *image, NSUInteger length);

/// 裁剪
UIKIT_EXTERN UIImage *UIImageCropToRect(UIImage *image, CGRect rect);

/// 根据颜色创建图像
UIKIT_EXTERN UIImage *UIImageFromColor(UIColor *color, CGSize size);

/// 高斯模糊
UIKIT_EXTERN UIImage *UIImageGaussianBlur(UIImage *image, CGFloat radius);

/// 正向图
UIKIT_EXTERN UIImage *UIImageOrientationToUp(UIImage *image);

/// 缩放
UIKIT_EXTERN UIImage *UIImageScaleToSize(UIImage *image, CGSize size);

/// 灰度图
UIKIT_EXTERN UIImage *UIImageToGrayscale(UIImage *image);

/// 缩略图
UIKIT_EXTERN UIImage *UIImageToThumbnail(UIImage *image, CGSize size, BOOL scaleAspectFill);

/// 图像尺寸
UIKIT_EXTERN CGSize UIImageSizeForScale(UIImage *image, CGFloat scale);
UIKIT_EXTERN CGSize UIImageSizeForScreenScale(UIImage *image);


/// UIImage (Extra)
@interface UIImage (Extra)

/// 根据颜色创建图像
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/// 高斯模糊
- (UIImage *)blurImage:(CGFloat)radius;

/// 压缩
- (NSData *)compressToData:(NSUInteger)length;

/// 裁剪
- (UIImage *)cropToRect:(CGRect)rect;

/// 灰度图
- (UIImage *)grayscaleImage;

/// 正向图
- (UIImage *)orientationToUp;

/// 缩放
- (UIImage *)scaleTo:(CGFloat)scale;
- (UIImage *)scaleToSize:(CGSize)size;

/// 缩略图
- (UIImage *)thumbnailImage:(CGSize)size aspect:(BOOL)fill;

@end

