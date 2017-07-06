//
// UIViewController+Extra.h
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

@interface UIViewController (Extra) <UIGestureRecognizerDelegate>
@property(nonatomic, readonly) UIViewController *topViewController; // The top view controller on the stack.
@property(nonatomic, readonly) UIViewController *visibleViewController; // Return modal view controller if it exists. Otherwise the top view controller.

- (UIViewController *)endViewController; // Implementation of topViewController
- (UIViewController *)topmostViewController; // Implementation of visibleViewController

- (void)setBackItemTitle:(NSString *)title;

- (void)setBackItemImage:(UIImage *)image;
- (void)setBackItemImage:(UIImage *)image title:(NSString *)title;

- (void)setBackItemTarget:(id)target action:(SEL)action;

- (void)setBackItemTintColor:(UIColor *)color;
- (void)setBackItemTitleFont:(UIFont *)font;

- (void)setTitleFont:(UIFont *)font;
- (void)setTitleColor:(UIColor *)color;

@end

@interface UINavigationController (Extra)
@property(nonatomic, readonly) UIViewController *prevViewController;
@property(nonatomic, readonly) UIViewController *rootViewController;

@end
