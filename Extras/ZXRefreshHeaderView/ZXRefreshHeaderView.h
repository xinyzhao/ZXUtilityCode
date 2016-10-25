//
// ZXRefreshHeaderView.h
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
#import <objc/runtime.h>

typedef void(^ZXRefreshHeaderBlock)(void);

typedef NS_ENUM(NSInteger, ZXRefreshState)
{
    ZXRefreshStateIdle,
    ZXRefreshStatePulling,
    ZXRefreshStateWillRefreshing,
    ZXRefreshStateRefreshing,
};

@protocol ZXRefreshHeaderProtocol <NSObject>

- (BOOL)attachToView:(UIView *)view;
- (BOOL)detach;

- (void)setPullingProgress:(CGFloat)progress;

- (BOOL)beginRefreshing;
- (BOOL)endRefreshing;

- (void)updateContentSize;

@end

@interface ZXRefreshHeaderView : UIView <ZXRefreshHeaderProtocol>
@property (nonatomic, assign) CGFloat contentHeight; // Default 40
@property (nonatomic, assign) CGFloat contentInset;  // Default 0
@property (nonatomic, assign) CGFloat contentOffset; // Default 0

+ (instancetype)headerWithRefreshingBlock:(ZXRefreshHeaderBlock)block;

- (BOOL)isRefreshing;

@end

@interface UIView (ZXRefreshHeaderView)
@property (nonatomic, strong) ZXRefreshHeaderView *refreshHeaderView;
@end