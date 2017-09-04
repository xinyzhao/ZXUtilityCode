//
// ZXToastView.m
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

#import "ZXToastView.h"

#define ZXToastViewMagicWidth round([UIScreen mainScreen].bounds.size.width * 0.1375)

@interface ZXToastView ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, getter=isRunning) BOOL running;
@property (nonatomic, getter=isRunaway) BOOL runaway;

@end

@implementation ZXToastView

+ (NSMutableArray *)toastQueue {
    static NSMutableArray *toastQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toastQueue = [[NSMutableArray alloc] init];
    });
    return toastQueue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentInset = UIEdgeInsetsMake(64.0, ZXToastViewMagicWidth, 64.0, ZXToastViewMagicWidth);
        self.contentMargin = 20.0;
        self.contentPadding = 8.0;
        self.duration = 3.0;
        self.fadeDuration = 0.2;
        self.position = ZXToastPositionCenter;
        self.tapToDismiss = YES;
        self.touchsLocked = YES;
        //
        _bubbleView = [[UIView alloc] initWithFrame:CGRectZero];
        _bubbleView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        [self addSubview:_bubbleView];
    }
    return self;
}

- (instancetype)initWithActivity:(NSString *)message {
    self = [self initWithMessage:message];
    if (self) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.bubbleView addSubview:_activityView];
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message {
    self = [self init];
    if (self) {
        if (message) {
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _messageLabel.font = [UIFont boldSystemFontOfSize:16.0];
            _messageLabel.numberOfLines = 0;
            _messageLabel.textAlignment = NSTextAlignmentLeft;
            _messageLabel.textColor = [UIColor whiteColor];
            _messageLabel.text = message;
            [self.bubbleView addSubview:_messageLabel];
        }
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
                       duration:(NSTimeInterval)duration {
    self = [self initWithMessage:message];
    if (self) {
        self.duration = duration;
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
                       duration:(NSTimeInterval)duration
                          image:(UIImage *)image {
    self = [self initWithMessage:message duration:duration];
    if (self) {
        if (image) {
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 40.0, 40.0)];
            _imageView.contentMode = UIViewContentModeScaleAspectFit;
            _imageView.image = image;
            [self.bubbleView addSubview:_imageView];
        }
    }
    return self;
}

#pragma mark Show

- (void)showInView:(UIView *)view {
    if (view == nil) {
        return;
    }
    if (self.activityView == nil && self.messageLabel == nil && self.imageView == nil) {
        return;
    }
    //
    self.alpha = 0.0;
    self.frame = view.bounds;
    [view addSubview:self];
    //
    _bubbleView.layer.cornerRadius = _contentMargin / 2;
    _bubbleView.layer.masksToBounds = YES;
    //
    if (self.messageLabel) {
        CGFloat width = self.bounds.size.width - (_contentInset.left + _contentInset.right);
        CGFloat height = self.bounds.size.height - (_contentInset.top + _contentInset.bottom);
        CGSize maxSize = CGSizeMake(width - _contentMargin * 2, height - _contentMargin * 2);
        CGSize msgSize = [self.messageLabel sizeThatFits:maxSize];
        // UILabel can return a size larger than the max size when the number of lines is 1
        msgSize = CGSizeMake(MIN(maxSize.width, msgSize.width),
                             MIN(maxSize.height, msgSize.height));
        self.messageLabel.frame = CGRectMake(0.0, 0.0, msgSize.width, msgSize.height);
    }
    //
    CGRect toastFrame = CGRectZero;
    if (self.activityView) {
        toastFrame.size.width = _contentMargin * 2 + self.activityView.bounds.size.width;
        toastFrame.size.height = _contentMargin * 2 + self.activityView.bounds.size.height;
    } else if (self.imageView) {
        toastFrame.size.width = _contentMargin * 2 + self.imageView.bounds.size.width;
        toastFrame.size.height = _contentMargin * 2 + self.imageView.bounds.size.height;
    }
    if (self.messageLabel) {
        CGFloat width = _contentMargin * 2 + self.messageLabel.bounds.size.width;
        toastFrame.size.width = MAX(toastFrame.size.width, width);
        if (self.activityView || self.imageView) {
            toastFrame.size.height += _contentPadding + self.messageLabel.bounds.size.height;
        } else {
            toastFrame.size.height = _contentMargin * 2 + self.messageLabel.bounds.size.height;
        }
    }
    //
    switch (self.position) {
        case ZXToastPositionTop:
            toastFrame.origin.x = (self.bounds.size.width - toastFrame.size.width) / 2;
            toastFrame.origin.y = _contentInset.top;
            break;
        case ZXToastPositionBottom:
            toastFrame.origin.x = (self.bounds.size.width - toastFrame.size.width) / 2;
            toastFrame.origin.y = self.bounds.size.height - toastFrame.size.height - _contentInset.bottom;
            break;
        case ZXToastPositionLeft:
            toastFrame.origin.x = _contentInset.left;
            toastFrame.origin.y = (self.bounds.size.height - toastFrame.size.height) / 2;
            break;
        case ZXToastPositionRight:
            toastFrame.origin.x = self.bounds.size.width - toastFrame.size.width - _contentInset.right;
            toastFrame.origin.y = (self.bounds.size.height - toastFrame.size.height) / 2;
            break;
        case ZXToastPositionTopLeft:
            toastFrame.origin.x = _contentInset.left;
            toastFrame.origin.y = _contentInset.top;
            break;
        case ZXToastPositionTopRight:
            toastFrame.origin.x = self.bounds.size.width - toastFrame.size.width - _contentInset.right;
            toastFrame.origin.y = _contentInset.top;
            break;
        case ZXToastPositionBottomLeft:
            toastFrame.origin.x = _contentInset.left;
            toastFrame.origin.y = self.bounds.size.height - toastFrame.size.height - _contentInset.bottom;
            break;
        case ZXToastPositionBottomRight:
            toastFrame.origin.x = self.bounds.size.width - toastFrame.size.width - _contentInset.right;
            toastFrame.origin.y = self.bounds.size.height - toastFrame.size.height - _contentInset.bottom;
            break;
        default:
            toastFrame.origin.x = (self.bounds.size.width - toastFrame.size.width) / 2;
            toastFrame.origin.y = (self.bounds.size.height - toastFrame.size.height) / 2;
            break;
    }
    self.bubbleView.frame = toastFrame;
    //
    if (self.activityView) {
        self.activityView.center = CGPointMake(toastFrame.size.width / 2, _contentMargin + self.activityView.bounds.size.height / 2);
    } else if (self.imageView) {
        self.imageView.center = CGPointMake(toastFrame.size.width / 2, _contentMargin + self.imageView.bounds.size.height / 2);
    }
    if (self.messageLabel) {
        CGRect frame = self.messageLabel.frame;
        frame.origin.x = (toastFrame.size.width - frame.size.width) / 2;
        if (self.activityView) {
            frame.origin.y = _contentPadding + self.activityView.frame.origin.y + self.activityView.frame.size.height;
        } else if (self.imageView) {
            frame.origin.y = _contentPadding + self.imageView.frame.origin.y + self.imageView.frame.size.height;
        } else {
            frame.origin.y = _contentMargin;
        }
        self.messageLabel.frame = frame;
    }
    //
    if (self.touchsLocked) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLocked:)];
        self.gestureRecognizers = @[tap];
        self.exclusiveTouch = YES;
        self.userInteractionEnabled = YES;
    }
    //
    if (self.isTapToDismiss && self.activityView == nil) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBubble:)];
        self.bubbleView.gestureRecognizers = @[tap];
        self.bubbleView.exclusiveTouch = YES;
        self.bubbleView.userInteractionEnabled = YES;
    }
    //
    ZXToastView *toastView = [[ZXToastView toastQueue] firstObject];
    if ([ZXToastView toastQueue].count > 1) {
        for (ZXToastView *view in [ZXToastView toastQueue]) {
            if (view != toastView) {
                [view removeFromSuperview];
            }
        }
        //
        NSRange range = NSMakeRange(1, [ZXToastView toastQueue].count - 1);
        [[ZXToastView toastQueue] removeObjectsInRange:range];
    }
    [[ZXToastView toastQueue] addObject:self];
    //
    if (toastView) {
        if (toastView.isRunning && !toastView.isRunaway) {
            [toastView hide];
        }
    } else {
        [self show];
    }
}

- (void)show {
    if (self.isRunning) {
        return;
    }
    self.running = YES;
    //
    if (self.activityView) {
        [self.activityView startAnimating];
    }
    //
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_fadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         weakSelf.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         if (weakSelf.activityView == nil) {
                             weakSelf.timer = [NSTimer timerWithTimeInterval:weakSelf.duration target:weakSelf selector:@selector(hideTimer:) userInfo:nil repeats:NO];
                             [[NSRunLoop mainRunLoop] addTimer:weakSelf.timer forMode:NSRunLoopCommonModes];
                         }
                     }];
}

#pragma mark Hide

- (void)hide {
    if (!self.isRunning || self.isRunaway) {
        return;
    }
    self.runaway = YES;
    self.running = NO;
    //
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    //
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:_fadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         weakSelf.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [weakSelf removeFromSuperview];
                         [[ZXToastView toastQueue] removeObject:weakSelf];
                         weakSelf.runaway = NO;
                         //
                         ZXToastView *toastView = [[ZXToastView toastQueue] lastObject];
                         if (toastView) {
                             [toastView show];
                         }
                     }];
}

- (void)hideTimer:(NSTimer *)timer {
    [self hide];
}

+ (void)hideAllToast {
    ZXToastView *toastView = [[ZXToastView toastQueue] firstObject];
    for (ZXToastView *view in [ZXToastView toastQueue]) {
        if (view != toastView) {
            [view removeFromSuperview];
        }
    }
    [[ZXToastView toastQueue] removeAllObjects];
    if (toastView.isRunning && !toastView.isRunaway) {
        [toastView hide];
    }
}

#pragma mark Touchs

- (IBAction)onLocked:(id)sender {
#ifdef DEBUG
    NSLog(@"Touchs is locked, set touchsLocked = NO to unlocked");
#endif
}

- (IBAction)onBubble:(id)sender {
    [self hide];
}

@end
