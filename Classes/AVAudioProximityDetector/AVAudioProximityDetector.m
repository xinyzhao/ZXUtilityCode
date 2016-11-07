//
// AVAudioProximityDetector.m
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

#import "AVAudioProximityDetector.h"

@implementation AVAudioProximityDetector

static AVAudioProximityDetector *_defaultDetector = nil;

+ (instancetype)defaultDetector {
    if (_defaultDetector == nil) {
        _defaultDetector = [[AVAudioProximityDetector alloc] init];
    }
    return _defaultDetector;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [self stopMonitoring];
}

- (BOOL)startMonitoring {
    // 添加近距离监听
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proximityStateDidChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    //
    [self proximityStateDidChange:nil];
    // 设置扬声器播放
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //
    return [UIDevice currentDevice].isProximityMonitoringEnabled;
}

- (void)stopMonitoring {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {
        [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    }
    //
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)proximityStateDidChange:(NSNotificationCenter *)notification {
    NSError *error;
    if ([UIDevice currentDevice].proximityState) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    }
    if (error) {
        NSLog(@"proximityStateDidChangeNotification: %@", error.localizedDescription);
    }
}

@end
