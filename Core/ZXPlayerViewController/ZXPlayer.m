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

@interface ZXPlayer ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id playerObserver;

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
    }
    return self;
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

- (void)remove {
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
    }
}

@end
