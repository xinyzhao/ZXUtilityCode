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

@property (nonatomic, assign) BOOL isEnded;

@end

@implementation ZXPlayer
@synthesize isPlaying = _isPlaying;

+ (instancetype)playerWithURL:(NSURL *)URL {
    return [[ZXPlayer alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        _URL = [URL copy];
        if (_URL) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_URL options:nil];
            if (asset) {
                _playerItem = [AVPlayerItem playerItemWithAsset:asset];
            }
        }
        if (_playerItem) {
            [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];
            [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            //
            _player = [AVPlayer playerWithPlayerItem:_playerItem];
        }
        if (_player) {
            if (@available(iOS 10.0, *)) {
                _player.automaticallyWaitsToMinimizeStalling = NO;
            }
            __weak typeof(self) weakSelf = self;
            _playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                if (weakSelf.isPlaying) {
                    if (weakSelf.playbackTime) {
                        weakSelf.playbackTime(weakSelf.currentTime, weakSelf.duration);
                    }
                }
            }];
            //
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        }
        //
        _brightnessFactor = 0.5;
        _seekingFactor = 0.5;
        _volumeFactor = 0.5;
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

#pragma mark Properties

- (void)setBrightnessFactor:(CGFloat)brightnessFactor {
    if (brightnessFactor < 0.00) {
        _brightnessFactor = 0.00;
    } else if (brightnessFactor > 1.00) {
        _brightnessFactor = 1.00;
    } else {
        _brightnessFactor = brightnessFactor;
    }
}

- (void)setSeekingFactor:(CGFloat)seekingFactor {
    if (seekingFactor < 0.00) {
        _seekingFactor = 0.00;
    } else if (seekingFactor > 1.00) {
        _seekingFactor = 1.00;
    } else {
        _seekingFactor = seekingFactor;
    }
}

- (void)setVolumeFactor:(CGFloat)volumeFactor {
    if (volumeFactor < 0.00) {
        _volumeFactor = 0.00;
    } else if (volumeFactor > 1.00) {
        _volumeFactor = 1.00;
    } else {
        _volumeFactor = volumeFactor;
    }
}

- (UIImage *)videoPreviewImage {
    UIImage *image = nil;
    if (self.playerItem.asset) {
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:self.playerItem.asset];
        generator.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        CMTime actualTime;
        NSError *error = nil;
        CGImageRef imageRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (imageRef) {
            image = [[UIImage alloc] initWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
    }
    return image;
}

#pragma mark Playing

- (BOOL)isReadToPlay {
    return _playerItem.status == AVPlayerItemStatusReadyToPlay;
}

- (void)play {
    if (self.isReadToPlay && !self.isPlaying) {
        _isPlaying = YES;
        //
        if (self.isEnded) {
            _isEnded = NO;
            [self seekToTime:0 andPlay:YES];
        } else {
            [self.player play];
        }
        //
        if (_playerStatus) {
            _playerStatus(ZXPlayerStatusPlaying, nil);
        }
    }
}

- (void)pause {
    if (self.isReadToPlay && self.isPlaying) {
        _isPlaying = NO;
        //
        [self.player pause];
        //
        if (_playerStatus) {
            _playerStatus(ZXPlayerStatusPaused, nil);
        }
    }
}

- (void)stop {
    [self pause];
    //
    if (_player) {
        if (_playerObserver) {
            [_player removeTimeObserver:_playerObserver];
            _playerObserver = nil;
        }
        _player = nil;
    }
    //
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        _playerItem = nil;
    }
}

#pragma mark Time

- (NSTimeInterval)currentTime {
    NSTimeInterval time = 0.f;
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        time = CMTimeGetSeconds(_playerItem.currentTime);
        if (time < 0.f) {
            time = 0.f;
        }
    }
    return time;
}

- (NSTimeInterval)duration {
    NSTimeInterval duration = 0.f;
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        duration = CMTimeGetSeconds(_playerItem.duration);
    }
    return duration;
}

- (void)seekToTime:(NSTimeInterval)time andPlay:(BOOL)play {
    if (self.isReadToPlay) {
        [self pause];
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
            if (play) {
                [weakSelf play];
            }
        }];
    }
}

#pragma mark Notifications

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    if (self.isPlaying) {
        _isPlaying = NO;
        _isEnded = YES;
        //
        [self.player pause];
        //
        if (_playerStatus) {
            _playerStatus(ZXPlayerStatusEnded, nil);
        }
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
    //
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
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
                if (_seekingFactor > 0.00) {
                    NSTimeInterval time = seekTime + (point.x / (pan.view.frame.size.width * _seekingFactor)) * self.duration;
                    if (time < 0) {
                        time = 0;
                    }
                    if (time > self.duration) {
                        time = self.duration;
                    }
                    [self seekToTime:time andPlay:pan.state == UIGestureRecognizerStateEnded];
                }
            } else if (isBrightness) {
                if (_brightnessFactor > 0.00) {
                    CGFloat y = point.y / (pan.view.frame.size.height * _brightnessFactor);
                    [UIScreen mainScreen].brightness = brightness - y;
                }
            } else {
                if (_volumeFactor > 0.00) {
                    CGFloat y = point.y / (pan.view.frame.size.height * _volumeFactor);
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
