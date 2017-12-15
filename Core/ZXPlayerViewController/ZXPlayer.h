//
// ZXPlayer.h
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

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, ZXPlayerStatus) {
    ZXPlayerStatusUnknown = AVPlayerStatusUnknown,
    ZXPlayerStatusReadyToPlay = AVPlayerStatusReadyToPlay,
    ZXPlayerStatusFailed = AVPlayerStatusFailed,
    ZXPlayerStatusPlaying,
    ZXPlayerStatusPaused,
    ZXPlayerStatusEnded,
};

@interface ZXPlayer : NSObject

@property (nonatomic, readonly) BOOL isReadToPlay;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isSeeking;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, copy) void (^playerStatus)(ZXPlayerStatus status, NSError *error);
@property (nonatomic, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);
@property (nonatomic, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readwrite) CGPoint panGestureRate; // Default is {0.5, 0.5}

+ (instancetype)playerWithURL:(NSURL *)URL;

- (instancetype)initWithURL:(NSURL *)URL;

- (void)attachToView:(UIView *)view;
- (void)detach;

- (void)play;
- (void)pause;
- (void)stop;

- (void)seekToTime:(NSTimeInterval)time andPlay:(BOOL)play;

@end
