//
// UIApplicationIdleTimer.m
//
// Copyright (c) 2017 Zhao Xin. All rights reserved.
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

#import "UIApplicationIdleTimer.h"

@implementation UIApplicationIdleTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.disabled = [UIApplication sharedApplication].idleTimerDisabled;
    }
    return self;
}

- (void)setDisabled:(BOOL)disabled {
    if (_disabled != disabled) {
        _disabled = disabled;
        if (!disabled) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
    }
    [UIApplication sharedApplication].idleTimerDisabled = disabled;
}

- (void)setEnabled:(BOOL)enabled {
    self.disabled = !enabled;
}

- (BOOL)isEnabled {
    return !self.disabled;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // 不自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = [UIApplication sharedIdleTimer].disabled;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // 自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end

@implementation UIApplication (IdleTimer)

+ (UIApplicationIdleTimer *)sharedIdleTimer {
    static UIApplicationIdleTimer *sharedIdleTimer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIdleTimer = [[UIApplicationIdleTimer alloc] init];
    });
    return sharedIdleTimer;
}

@end