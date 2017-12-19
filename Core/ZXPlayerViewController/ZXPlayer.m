//
// ZXPlayer.m
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

#import "ZXPlayer.h"
#import "ZXBrightnessView.h"

@interface ZXPlayer ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id playerObserver;

@property (nonatomic, weak) UIView *attachView;
@property (nonatomic, strong) ZXBrightnessView *brightnessView;
@property (nonatomic, strong) UISlider *volumeSlider;

@end

@implementation ZXPlayer
@synthesize isPlaying = _isPlaying;
@synthesize isSeeking = _isSeeking;
@synthesize playerLayer = _playerLayer;

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[ZXPlayer alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        if (URL) {
            _playerItem = [AVPlayerItem playerItemWithURL:URL];
            [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];
            [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
            [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        }
        if (_playerItem) {
            __weak typeof(self) weakSelf = self;
            _player = [AVPlayer playerWithPlayerItem:_playerItem];
            if (@available(iOS 10.0, *)) {
                _player.automaticallyWaitsToMinimizeStalling = NO;
            }
            _playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                if (!weakSelf.isSeeking) {
                    if (weakSelf.playbackTime) {
                        weakSelf.playbackTime(weakSelf.currentTime, weakSelf.duration);
                    }
                }
            }];
        }
        if (_player) {
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        }
        //
        _panGestureRate = CGPointMake(0.5, 0.5);
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecognizer:)];
        //
        _brightnessView = [ZXBrightnessView brightnessView];
        [_brightnessView addObserver];
        //
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return self;
}

- (void)dealloc {
    if (_brightnessView) {
        [_brightnessView removeObserver];
        _brightnessView = nil;
    }
    [self detach];
    [self stop];
}

#pragma mark Attach & Detach

- (void)attachToView:(UIView *)view {
    _attachView = view;
    if (_attachView) {
        if (_playerLayer) {
            _playerLayer.frame = _attachView.bounds;
            [_attachView.layer insertSublayer:_playerLayer atIndex:0];
            [_attachView.layer addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:NULL];
        }
        if (_panGestureRecognizer) {
            [_attachView addGestureRecognizer:_panGestureRecognizer];
        }
    }
}

- (void)detach {
    if (_attachView) {
        [_playerLayer removeFromSuperlayer];
        [_attachView removeGestureRecognizer:_panGestureRecognizer];
        [_attachView.layer removeObserver:self forKeyPath:@"bounds"];
        _attachView = nil;
    }
}

#pragma mark Playing

- (BOOL)isReadToPlay {
    return _playerItem.status == AVPlayerItemStatusReadyToPlay;
}

- (BOOL)isPlaying {
    return _isPlaying;
}

- (void)play {
    if ([self isReadToPlay]) {
        if (self.duration - self.currentTime <= 0.f) {
            [self seekToTime:0 andPlay:YES];
        } else {
            [self.player play];
            //
            _isPlaying = YES;
            if (_playerStatus) {
                _playerStatus(ZXPlayerStatusPlaying, nil);
            }
        }
    }
}

- (void)pause {
    if ([self isReadToPlay]) {
        [_player pause];
        //
        _isPlaying = NO;
        if (_playerStatus) {
            _playerStatus(ZXPlayerStatusPaused, nil);
        }
    }
}

- (void)stop {
    _isPlaying = NO;
    if (_player) {
        [_player pause];
        if (_playerObserver) {
            [_player removeTimeObserver:_playerObserver];
            _playerObserver = nil;
        }
        _player = nil;
    }
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        _playerItem = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Time

- (NSTimeInterval)currentTime {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds(_playerItem.currentTime);
    }
    return 0.f;
}

- (NSTimeInterval)duration {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds(_playerItem.duration);
    }
    return 0.f;
}

- (void)seekToTime:(NSTimeInterval)time andPlay:(BOOL)play {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self pause];
        _isSeeking = !play;
        //
        NSTimeInterval duration = self.duration;
        if (time > duration) {
            time = duration;
        }
        CMTime toTime = CMTimeMakeWithSeconds(floor(time), 1);
        //
        __weak typeof(self) weakSelf = self;
        [_playerItem seekToTime:toTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            if (weakSelf.playbackTime) {
                weakSelf.playbackTime(time, duration);
            }
            if (!weakSelf.isSeeking) {
                [weakSelf play];
            }
        }];
    }
}

#pragma mark Notifications

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    if ([self isReadToPlay]) {
        [_player pause];
    }
    //
    _isPlaying = NO;
    if (_playerStatus) {
        _playerStatus(ZXPlayerStatusEnded, nil);
    }
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        ZXPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (_playerStatus) {
            _playerStatus(status, _playerItem.error);
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        CMTimeRange timeRange = [_playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval loaded = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval duration = self.duration;
        if (_loadedTime) {
            _loadedTime(loaded, duration);
        }
    } else if ([keyPath isEqualToString:@"bounds"]) {
        CGRect bounds = [[change objectForKey:@"new"] CGRectValue];
        _playerLayer.frame = bounds;
    }
}

#pragma mark Actions

- (void)onPanGestureRecognizer:(id)sender {
    UIPanGestureRecognizer *pan = sender;
    // 上下滑动：左侧亮度/右侧音量
    static BOOL isBrightness = NO;
    // 左右滑动：时间定位
    static BOOL isSeeking = NO;
    // 亮度/音量/时间
    static CGFloat brightness = 0;
    static float volume = 0;
    static NSTimeInterval seekTime = 0;
    // 比率
    CGPoint rate = _panGestureRate;
    if (rate.x > 1.f) {
        rate.x = 1.f;
    }
    if (rate.y > 1.f) {
        rate.y = 1.f;
    }
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            // 我们要响应水平移动和垂直移动
            // 根据上次和本次移动的位置，算出一个速率的point
            // 使用绝对值来判断移动的方向
            CGPoint velocity = [pan velocityInView:pan.view];
            CGFloat x = fabs(velocity.x);
            CGFloat y = fabs(velocity.y);
            isSeeking = x > y;
            if (isSeeking) {
                seekTime = self.currentTime;
            } else {
                CGPoint point = [pan locationInView:pan.view];
                isBrightness = point.x < pan.view.frame.size.width / 2;
                if (isBrightness) {
                    brightness = [UIScreen mainScreen].brightness;
                } else {
                    volume = self.volumeSlider.value;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [pan translationInView:pan.view];
            if (isSeeking) {
                if (rate.x > 0.f) {
                    NSTimeInterval time = seekTime + (point.x / (pan.view.frame.size.width * rate.x)) * self.duration;
                    NSLog(@"---x---[%.2f %.2f]", point.x, time - seekTime);
                    if (time < 0) {
                        time = 0;
                    }
                    if (time > self.duration) {
                        time = self.duration;
                    }
                    [self seekToTime:time andPlay:pan.state == UIGestureRecognizerStateEnded];
                }
            } else if (rate.y > 0.00f) {
                CGFloat y = point.y / (pan.view.frame.size.height * rate.y);
                if (isBrightness) {
                    [UIScreen mainScreen].brightness = brightness - y;
                } else if (fabs(self.volumeSlider.value - (volume - y)) > 0.05) {
                    self.volumeSlider.value = volume - y;
                }
            }
            break;
        }
        default:
            break;
    }
}

@end
