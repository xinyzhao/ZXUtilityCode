//
// ZXPopoverWindow.m
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

#import "ZXPopoverWindow.h"

#define ZXPopoverWindowPresentColor [[UIColor blackColor] colorWithAlphaComponent:.4]
#define ZXPopoverWindowPresentDuration .3

#define ZXPopoverWindowDismissColor [UIColor clearColor]
#define ZXPopoverWindowDismissDuration .2

@interface ZXPopoverWindow () <UIGestureRecognizerDelegate>

@end

@implementation ZXPopoverWindow

- (void)presentView:(UIView *)view {
    _presentedView = view;
    if (_presentedView) {
        CGRect frame = self.frame;
        frame.origin.y = self.frame.size.height;
        frame.size.height = _presentedView.frame.size.height;
        _presentedView.frame = frame;
        [self addSubview:_presentedView];
    }
    self.backgroundColor = ZXPopoverWindowDismissColor;
    self.hidden = NO;
    //
    __weak typeof(self) weakSelf = self;
    CGRect frame = _presentedView.frame;
    frame.origin.y = self.frame.size.height - _presentedView.frame.size.height;
    [UIView animateWithDuration:ZXPopoverWindowPresentDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.backgroundColor = ZXPopoverWindowPresentColor;
        _presentedView.frame = frame;
    } completion:^(BOOL finished) {
        weakSelf.backgroundColor = ZXPopoverWindowPresentColor;
        _presentedView.frame = frame;
        //
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(dismiss)];
        tap.delegate = self;
        [weakSelf addGestureRecognizer:tap];
    }];
}

- (void)dismiss {
    __weak typeof(self) weakSelf = self;
    CGRect frame = _presentedView.frame;
    frame.origin.y = self.frame.size.height;
    [UIView animateWithDuration:ZXPopoverWindowDismissDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _presentedView.frame = frame;
        weakSelf.backgroundColor = ZXPopoverWindowDismissColor;
    } completion:^(BOOL finished) {
        [_presentedView removeFromSuperview];
        weakSelf.hidden = YES;
    }];
}

#pragma mark <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.presentedView];
    return !CGRectContainsPoint(self.presentedView.bounds, point);
}

@end