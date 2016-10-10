//
// ZXImageViewController.h
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
#import "ZXImageViewAction.h"

@interface ZXImageViewController : UIViewController
@property (nonatomic, strong) NSArray *dataArray; // 支持 UIImage 和 NSURL
@property (nonatomic, assign) CGFloat itemSpacing; // Defalut 10.f
@property (nonatomic, assign) NSUInteger displayedIndex; // Defalut 0

@property (nonatomic, strong) NSArray *actions; // 长按动作 NSArray <ZXImageViewAction *>
@property (nonatomic, strong) NSString *actionTitle; // 动作标题
@property (nonatomic, strong) NSString *actionCancel; // 取消标题
@property (nonatomic, strong) ZXImageView *actionImageView; // Default nil

- (void)setImage:(UIImage *)image;
- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholder:(UIImage *)image;

@end
