//
// ZXPlayerViewController.m
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

#import "ZXPlayerViewController.h"

@interface ZXPlayerViewController ()
@property (nonatomic, weak) IBOutlet UIView *controlView;
@property (nonatomic, weak) IBOutlet UIToolbar *topBar;
@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomBar;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UISlider *progressSlider;
@property (nonatomic, weak) IBOutlet UIProgressView *loadedProgressView;
@property (nonatomic, weak) IBOutlet UIProgressView *bottomProgressView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *quitButton;

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) id playerObserver;
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, strong) NSTimer *hideControlsTimer;

@end

@implementation ZXPlayerViewController
@synthesize isPlaying = _isPlaying;
@synthesize isSeeking = _isSeeking;

- (instancetype)initWithURL:(NSURL *)URL {
    self = [self initWithNibName:@"ZXPlayerViewController" bundle:nil];
    if (self) {
        _showsPlaybackControls = YES;
        self.URL = URL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //
    [self stop];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //
    self.playerLayer.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return !_showsPlaybackControls; // 显示/隐藏 状态栏
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark Orientation

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIInterfaceOrientationLandscapeLeft;
            break;
        default:
            break;
    }
    return orientation;
}

#pragma mark Functions

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    if (URL) {
        _playerItem = [AVPlayerItem playerItemWithURL:URL];
        [_playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    if (_playerItem) {
        __weak typeof(self) weakSelf = self;
        _player = [AVPlayer playerWithPlayerItem:_playerItem];
        _playerObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            if (!weakSelf.isSeeking) {
                NSTimeInterval currentTime = weakSelf.currentTime;
                NSTimeInterval duration = weakSelf.duration;
                CGFloat progress = currentTime / duration;
                weakSelf.progressSlider.value = progress;
                weakSelf.bottomProgressView.progress = progress;
                [weakSelf setCurrentTime:currentTime];
            }
        }];
    }
    if (_player) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.view.layer insertSublayer:_playerLayer atIndex:0];
    }
}

- (BOOL)isReadToPlay {
    return _playerItem.status == AVPlayerItemStatusReadyToPlay;
}

- (BOOL)isPlaying {
    return _isPlaying;
}

- (void)play {
    if ([self isReadToPlay]) {
        _isPlaying = YES;
        self.playButton.selected = _isPlaying;
        //
        if (self.duration - self.currentTime <= 0.f) {
            [self seekToTime:0];
        } else {
            [self.player play];
            //
            if (_showsPlaybackControls) {
                [self startHideControlsTimer];
            }
        }
    }
}

- (void)pause {
    if ([self isReadToPlay]) {
        [_player pause];
        //
        _isPlaying = NO;
        _playButton.selected = _isPlaying;
        //
        if (_showsPlaybackControls) {
            [self stopHideControlsTimer];
        } else {
            self.showsPlaybackControls = YES;
        }
    }
}

- (void)stop {
    [self stopHideControlsTimer];
    if (_player) {
        [_player pause];
        if (_playerObserver) {
            [_player removeTimeObserver:_playerObserver];
            _playerObserver = nil;
        }
    }
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSTimeInterval)duration {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds(_playerItem.duration);
    }
    return 0.f;
}

- (void)seekToTime:(NSTimeInterval)time {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
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
            [weakSelf setCurrentTime:floor(time)];
            if (!weakSelf.isSeeking) {
                [weakSelf play];
            }
        }];
    }
}

- (void)setShowsPlaybackControls:(BOOL)showsPlaybackControls {
    _showsPlaybackControls = showsPlaybackControls;
    [self stopHideControlsTimer];
    if (_showsPlaybackControls) {
        _bottomView.alpha = 0.f;
        _bottomView.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.bottomView.alpha = 1.f;
            weakSelf.bottomProgressView.alpha = 0.f;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            weakSelf.bottomView.alpha = 1.f;
            weakSelf.bottomProgressView.alpha = 0.f;
            if (weakSelf.isPlaying) {
                [weakSelf startHideControlsTimer];
            }
        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:.3 animations:^{
            weakSelf.bottomView.alpha = 0.f;
            weakSelf.bottomProgressView.alpha = 1.f;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            weakSelf.bottomView.hidden = YES;
            weakSelf.bottomProgressView.alpha = 1.f;
        }];
    }
}

- (NSTimeInterval)currentTime {
    if (_playerItem.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds(_playerItem.currentTime);
    }
    return 0.f;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    NSTimeInterval duration = self.duration;
    NSTimeInterval remainingTime = duration - currentTime;
    NSInteger hours = floor(remainingTime / 3600);
    NSInteger minutes = floor((remainingTime - 3600 * hours) / 60);
    NSInteger seconds = remainingTime - 3600 * hours - 60 * minutes;
    _timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (UISlider *)volumeSlider {
    if (_volumeSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeSlider;
}

#pragma mark Actions

- (IBAction)onPlay:(id)sender {
    UIButton *button = sender;
    BOOL isPlaying = !button.selected;
    if (isPlaying) {
        [self play];
    } else {
        [self pause];
    }
}

- (IBAction)onQuit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSliderToucheBegan:(id)sender {
    _isSeeking = YES;
}

- (IBAction)onSliderValueChanged:(id)sender {
    UISlider *slider = sender;
    NSTimeInterval time = self.duration * slider.value;
    [self seekToTime:time];
}

- (IBAction)onSliderToucheEnded:(id)sender {
    _isSeeking = NO;
    UISlider *slider = sender;
    NSTimeInterval time = self.duration * slider.value;
    [self seekToTime:time];
}

- (IBAction)onPanGestureRecognizer:(id)sender {
    UIPanGestureRecognizer *pan = sender;
    
    // 起始位置
    static CGPoint startPoint = {0, 0};
    // 移动方向: 横向定位/垂直音量
    static BOOL isSeeking = NO;
    // 定位时间
    static NSTimeInterval seekTime = 0;
    // 当前音量
    static float volumeValue = 0;
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            startPoint = [pan translationInView:pan.view];
            // 我们要响应水平移动和垂直移动
            // 根据上次和本次移动的位置，算出一个速率的point
            // 使用绝对值来判断移动的方向
            CGPoint velocityPoint = [pan velocityInView:pan.view];
            CGFloat x = fabs(velocityPoint.x);
            CGFloat y = fabs(velocityPoint.y);
            isSeeking = x > y;
            if (isSeeking) {
                seekTime = [self currentTime];
            } else {
                volumeValue = self.volumeSlider.value;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [pan translationInView:pan.view];
            CGPoint offset = CGPointMake(point.x - startPoint.x, point.y - startPoint.y);
            if (isSeeking) {
                NSTimeInterval time = seekTime + (offset.x / 8);
                if (time < 0) {
                    time = 0;
                }
                if (time > self.duration) {
                    time = self.duration;
                }
                CGFloat progress = time / self.duration;
                _progressSlider.value = progress;
                _bottomProgressView.progress = progress;
                _isSeeking = pan.state == UIGestureRecognizerStateChanged;
                [self seekToTime:time];
            } else {
                self.volumeSlider.value = volumeValue - (offset.y / 80);
            }
            break;
        }

        default:
            break;
    }
}

- (IBAction)onTapGestureRecognizer:(id)sender {
    self.showsPlaybackControls = !_showsPlaybackControls;
}

#pragma mark Timer

- (void)startHideControlsTimer {
    [self stopHideControlsTimer];
    if (self.hideControlsTimer == nil) {
        self.hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onHideControlsTimer:) userInfo:nil repeats:NO];
    }
}

- (void)stopHideControlsTimer {
    if ([self.hideControlsTimer isValid]) {
        [self.hideControlsTimer invalidate];
    }
    self.hideControlsTimer = nil;
}

- (void)onHideControlsTimer:(NSTimer *)hideControlsTimer {
    if (_showsPlaybackControls) {
        self.showsPlaybackControls = NO;
    }
}

#pragma mark Notifications

- (void)didPlayToEndTime:(NSNotification *)notification {
    [self pause];
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        if (status == AVPlayerStatusReadyToPlay) {
            self.playButton.enabled = YES;
            self.progressSlider.enabled = YES;
            [self setCurrentTime:self.currentTime];
            [self play];
        } else if (status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        } else {
            NSLog(@"AVPlayerStatusUnknown");
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        CMTimeRange timeRange = [_playerItem.loadedTimeRanges.firstObject CMTimeRangeValue];
        NSTimeInterval loaded = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval duration = self.duration;
        self.loadedProgressView.progress = loaded / duration;
    }
}

#pragma mark <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    return YES;
}

@end

#pragma mark - UIApplication (ZXPlayerViewController)

@interface UIApplication (ZXPlayerViewController)

@end

@implementation UIApplication (ZXPlayerViewController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(supportedInterfaceOrientationsForWindow:) with:@selector(supportedInterfaceOrientationsForPTVideoPlayerViewController:)];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForPTVideoPlayerViewController:(nullable UIWindow *)window {
    if ([window.rootViewController.topLevelViewController isKindOfClass:[ZXPlayerViewController class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return [self supportedInterfaceOrientationsForPTVideoPlayerViewController:window];
}

@end
