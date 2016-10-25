//
// ZXAlertView.m
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

#import "ZXAlertView.h"

#define _IOS_VERSION_       [[UIDevice currentDevice].systemVersion floatValue]
#define _IOS_8_OR_LATER_    (_IOS_VERSION_ >= 8.0)
#define _IOS_8_OR_EARLIER_  (_IOS_VERSION_ < 8.0)

typedef void (^ZXAlertActionHandler)(ZXAlertAction *action);

@interface ZXAlertAction ()
@property (nonatomic, copy) ZXAlertActionHandler handler;

@end

@implementation ZXAlertAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(ZXAlertAction *action))handler {
    return [[[self class] alloc] initWithTitle:title handler:handler];
};

- (instancetype)initWithTitle:(NSString *)title handler:(void (^)(ZXAlertAction *action))handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.handler = handler;
    }
    return self;
}

@end

@interface ZXAlertView () <UIAlertViewDelegate>
@property (nonatomic, strong) NSMutableArray *alertActions;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation ZXAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction otherActions:(ZXAlertAction *)otherActions, ... {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        //
        if (_IOS_8_OR_EARLIER_) {
            self.alertActions = [NSMutableArray array];
            if (cancelAction) {
                [self.alertActions addObject:cancelAction];
            }
            //
            self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelAction.title otherButtonTitles:nil];
            [self.alertView insertSubview:self atIndex:0];
            //
            if (otherActions) {
                [self.alertActions addObject:otherActions];
                [self.alertView addButtonWithTitle:otherActions.title ? otherActions.title : @""];
                //
                va_list vaList;
                va_start(vaList, otherActions);
                id obj;
                while ((obj = va_arg(vaList, id))) {
                    if ([obj isKindOfClass:[ZXAlertAction class]]) {
                        ZXAlertAction *otherAction = obj;
                        [self.alertActions addObject:obj];
                        [self.alertView addButtonWithTitle:otherAction.title];
                    }
                }
                va_end(vaList);
            }
            
        } else {
            self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            if (cancelAction) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:cancelAction.title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    if (cancelAction.handler) {
                        cancelAction.handler(cancelAction);
                    }
                }];
                [self.alertController addAction:alertAction];
            }
            //
            if (otherActions) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:otherActions.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if (otherActions.handler) {
                        otherActions.handler(otherActions);
                    }
                }];
                [self.alertController addAction:alertAction];
                //
                va_list vaList;
                va_start(vaList, otherActions);
                id obj;
                while ((obj = va_arg(vaList, id))) {
                    if ([obj isKindOfClass:[ZXAlertAction class]]) {
                        ZXAlertAction *otherAction = obj;
                        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:otherAction.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            if (otherAction.handler) {
                                otherAction.handler(otherAction);
                            }
                        }];
                        [self.alertController addAction:alertAction];
                    }
                }
                va_end(vaList);
            }
        }
    }
    return self;
}

- (void)showInViewController:(UIViewController *)viewController {
    if (_IOS_8_OR_EARLIER_) {
        [self.alertView show];
    } else if (self.alertController) {
        [viewController presentViewController:self.alertController animated:YES completion:nil];
    }
}

#pragma mark <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ZXAlertAction *action = self.alertActions[buttonIndex];
    if (action.handler) {
        action.handler(action);
    }
    [self removeFromSuperview];
}

@end
