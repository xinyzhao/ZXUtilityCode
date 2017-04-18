//
// ZXAlertView.m
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

#import "ZXAlertView.h"

#ifndef _SYSTEM_VERSION_
#define _SYSTEM_VERSION_    [[UIDevice currentDevice].systemVersion floatValue]
#endif//_SYSTEM_VERSION_

#ifndef _IOS_8_OR_EARLY_
#define _IOS_8_OR_EARLY_    (_SYSTEM_VERSION_ <  8.0)
#endif//_IOS_8_OR_EARLY_

#ifndef _IOS_8_OR_LATER_
#define _IOS_8_OR_LATER_    (_SYSTEM_VERSION_ >= 8.0)
#endif//_IOS_8_OR_LATER_

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

@interface ZXAlertView () <UIAlertViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *alertActions;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) NSMutableArray<UITextField *> *textFieldArray;

@end

@implementation ZXAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction otherActions:(ZXAlertAction *)otherActions, ... {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.textFieldArray = [[NSMutableArray alloc] init];
        //
        if (_IOS_8_OR_EARLY_) {
            //
            self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelAction.title otherButtonTitles:nil];
            [self.alertView insertSubview:self atIndex:0];
            //
            self.alertActions = [NSMutableArray array];
            if (cancelAction) {
                [self.alertActions addObject:cancelAction];
            }
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
            //
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
    //
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message cancelAction:(ZXAlertAction *)cancelAction destructiveAction:(ZXAlertAction *)destructiveAction otherActions:(ZXAlertAction *)otherActions, ... {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.textFieldArray = [[NSMutableArray alloc] init];
        //
        if (_IOS_8_OR_EARLY_) {
            //
            self.actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:cancelAction.title destructiveButtonTitle:destructiveAction.title otherButtonTitles:nil];
            [self.actionSheet insertSubview:self atIndex:0];
            //
            self.alertActions = [NSMutableArray array];
            if (destructiveAction) {
                [self.alertActions addObject:destructiveAction];
            }
            //
            if (otherActions) {
                [self.alertActions addObject:otherActions];
                [self.actionSheet addButtonWithTitle:otherActions.title ? otherActions.title : @""];
                //
                va_list vaList;
                va_start(vaList, otherActions);
                id obj;
                while ((obj = va_arg(vaList, id))) {
                    if ([obj isKindOfClass:[ZXAlertAction class]]) {
                        ZXAlertAction *otherAction = obj;
                        [self.alertActions addObject:obj];
                        [self.actionSheet addButtonWithTitle:otherAction.title];
                    }
                }
                va_end(vaList);
            }
            //
            if (cancelAction) {
                [self.alertActions addObject:cancelAction];
            }
            
        } else {
            //
            self.alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
            //
            if (cancelAction) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:cancelAction.title style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    if (cancelAction.handler) {
                        cancelAction.handler(cancelAction);
                    }
                }];
                [self.alertController addAction:alertAction];
            }
            //
            if (destructiveAction) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:destructiveAction.title style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    if (destructiveAction.handler) {
                        destructiveAction.handler(destructiveAction);
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
    //
    return self;
}

- (void)addTextField:(void (^)(UITextField *textField))configurationHandler {
    if (_IOS_8_OR_EARLY_) {
        UITextField *textField = [self.alertView textFieldAtIndex:self.textFieldArray.count];
        if (textField) {
            [self.textFieldArray addObject:textField];
        }
        if (configurationHandler) {
            configurationHandler(textField);
        }
    } else {
        __weak typeof(self) weakSelf = self;
        [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            [weakSelf.textFieldArray addObject:textField];
            if (configurationHandler) {
                configurationHandler(textField);
            }
        }];
    }
}

- (NSArray<UITextField *> *)textFields {
    return [self.textFieldArray copy];
}

- (void)showInViewController:(UIViewController *)viewController {
    if (_IOS_8_OR_EARLY_) {
        if (self.alertView) {
            [self.alertView show];
        }
        if (self.actionSheet) {
            if (viewController.tabBarController) {
                [self.actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            } else {
                [self.actionSheet showInView:viewController.view];
            }
        }
    } else if (self.alertController) {
        [viewController presentViewController:self.alertController animated:YES completion:nil];
    }
}

#pragma mark <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self removeFromSuperview];
    ZXAlertAction *action = self.alertActions[buttonIndex];
    if (action.handler) {
        action.handler(action);
    }
}

#pragma mark <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self removeFromSuperview];
    ZXAlertAction *action = self.alertActions[buttonIndex];
    if (action.handler) {
        action.handler(action);
    }
}

@end
