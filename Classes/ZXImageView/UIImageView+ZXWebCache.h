//
// UIImageView+ZXWebCache.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
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

@interface UIImageView (ZXWebCache)

/**
 Set image with URL
 
 @param imageURL Image URL
 */
- (void)zx_setImageWithURL:(NSURL *)imageURL;

/**
 Set image with URL and placeholder image
 
 @param imageURL Image URL
 @param image Placeholder image
 */
- (void)zx_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)image;

/**
 Set image with URL and placeholder image, completion block
 
 @param imageURL Image URL
 @param image Placeholder image
 @param completion Completion block
 */
- (void)zx_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)image completion:(void(^)(UIImage *image, NSError *error, NSURL *imageURL))completion;
                                                                                      
/**
 Cacnel image load
 */
- (void)zx_cancelImageLoad;

@end
