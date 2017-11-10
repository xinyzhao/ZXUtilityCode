//
// ZXPlayerViewController.h
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

@interface ZXPlayerViewController : UIViewController
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, readonly) BOOL isReadToPlay;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isSeeking;

@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, copy) void (^playerStatus)(AVPlayerStatus status, NSError *error);
@property (nonatomic, copy) void (^playbackTime)(NSTimeInterval time, NSTimeInterval duration);
@property (nonatomic, copy) void (^playbackDidEnd)(void);
@property (nonatomic, copy) void (^loadedTime)(NSTimeInterval time, NSTimeInterval duration);

@property (nonatomic, assign) CGFloat velocityOfSeeking; // Default is 1.0
@property (nonatomic, assign) CGFloat velocityOfVolume; // Default is 1.0

@property (nonatomic, assign) BOOL shouldAutorotate; // Default is YES
@property (nonatomic, assign) UIInterfaceOrientationMask supportedInterfaceOrientations; // Default is UIInterfaceOrientationMaskAllButUpsideDown/UIInterfaceOrientationMaskPortrait when shouldAutorotate YES/NO

- (instancetype)initWithURL:(NSURL *)URL;

- (void)play;
- (void)pause;
- (void)stop;

- (void)seekToTime:(NSTimeInterval)time andPlay:(BOOL)play;

@end
