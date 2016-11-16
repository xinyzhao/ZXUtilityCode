//
// ZXRefreshProgressView.h
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

#import "ZXRefreshHeaderView.h"

/// 环形进度视图
@class ZXCircularProgressView;

/// 进度刷新视图
@interface ZXRefreshProgressView : ZXRefreshHeaderView
/// 环形进度视图
@property (nonatomic, strong) ZXCircularProgressView *progressView;
/// 环形半径, 默认 16
@property (nonatomic, assign) CGFloat circularRadius;
/// 动画时间, 默认 0.8秒
@property (nonatomic, assign) CGFloat animationDuration;

@end

/// 环形进度视图
@interface ZXCircularProgressView : UIView
/// 闭合完整度，默认 0.8
@property (nonatomic, assign) CGFloat integrity;
/// 线宽，默认 1.5
@property (nonatomic, assign) CGFloat lineWidth;
/// 进度，范围 0.0 - 1.0
@property (nonatomic, assign) CGFloat progress;
/// 进度颜色
@property (nonatomic, copy) UIColor *progressColor;

@end

