//
// ZXAlertView.h
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

@interface ZXAlertAction : NSObject
@property (nonatomic, strong) NSString *title;

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(ZXAlertAction *action))handler;
- (instancetype)initWithTitle:(NSString *)title handler:(void (^)(ZXAlertAction *action))handler;

@end

@interface ZXAlertView : UIView
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

/// Link UIAlertView, compatible with iOS 7,8
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction otherActions:(ZXAlertAction *)otherActions, ... NS_REQUIRES_NIL_TERMINATION;

/// Link UIActionSheet, compatible with iOS 7,8
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction destructiveAction:(ZXAlertAction *)destructiveAction otherActions:(ZXAlertAction *)otherActions, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showInViewController:(UIViewController *)viewController;

@end
