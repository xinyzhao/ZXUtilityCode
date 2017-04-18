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

/// 根据颜色创建图像
UIKIT_EXTERN UIImage *UIImageFromColor(UIColor *color, CGSize size);

/// 压缩
UIKIT_EXTERN NSData *UIImageCompress(UIImage *image, NSUInteger length);

/// 裁剪
UIKIT_EXTERN UIImage *UIImageCropping(UIImage *image, CGRect rect);

/// 按比例缩放
UIKIT_EXTERN UIImage *UIImageScaling(UIImage *image, CGFloat scale);

/// 缩放到指定大小
UIKIT_EXTERN UIImage *UIImageResizing(UIImage *image, CGSize size);

/// 缩略图
UIKIT_EXTERN UIImage *UIImageThumbnail(UIImage *image, CGSize size, BOOL aspectFill);

/// 正向图
UIKIT_EXTERN UIImage *UIImageCorrectOrientation(UIImage *image);

/// 灰度图
UIKIT_EXTERN UIImage *UIImageGrayscale(UIImage *image);

/// 高斯模糊
UIKIT_EXTERN UIImage *UIImageGaussianBlur(UIImage *image, CGFloat radius);

/// 图像尺寸
UIKIT_EXTERN CGSize UIImageSizeForScale(UIImage *image, CGFloat scale);
UIKIT_EXTERN CGSize UIImageSizeForWidth(UIImage *image, CGFloat width);
UIKIT_EXTERN CGSize UIImageSizeForHeight(UIImage *image, CGFloat height);

/// 屏幕尺寸
UIKIT_EXTERN CGSize UIImageSizeForScreenScale(UIImage *image);
UIKIT_EXTERN CGSize UIImageSizeForScreenWidth(UIImage *image);
UIKIT_EXTERN CGSize UIImageSizeForScreenHeight(UIImage *image);

/// UIImage (Extra)
@interface UIImage (Extra)

/// 从.bundle内加载图片，不能用imageNamed:inBundle:，和CameraKit.framework冲突
+ (UIImage *)imageNamed:(NSString *)name bundleNamed:(NSString *)bundle;

/// 根据颜色创建图像
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/// 压缩
- (NSData *)compressedData:(NSUInteger)length;

/// 裁剪
- (UIImage *)imageWithRect:(CGRect)rect;

/// 缩放
- (UIImage *)imageWithScale:(CGFloat)scale;
- (UIImage *)imageWithSize:(CGSize)size;

/// 缩略图
- (UIImage *)thumbnailWithSize:(CGSize)size aspectFill:(BOOL)aspectFill;

/// 正向图
- (UIImage *)correctOrientationImage;

/// 灰度图
- (UIImage *)grayscaleImage;

/// 高斯模糊
- (UIImage *)imageWithBlurRadius:(CGFloat)radius;

/// 图像尺寸
- (CGSize)sizeForScale:(CGFloat)scale;
- (CGSize)sizeForWidth:(CGFloat)width;
- (CGSize)sizeForHeight:(CGFloat)height;

/// 屏幕尺寸
- (CGSize)sizeForScreenScale;
- (CGSize)sizeForScreenWidth;
- (CGSize)sizeForScreenHeight;

@end

