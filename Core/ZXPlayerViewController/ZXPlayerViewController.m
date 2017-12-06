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
#import "UIViewController+Extra.h"
#import "NSObject+Extra.h"

@interface ZXPlayerViewController ()
@property (nonatomic, strong) UISlider *volumeSlider;

@end

@implementation ZXPlayerViewController

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (self) {
        self.player = [ZXPlayer playerWithURL:URL];
        if (self.player.playerLayer) {
            [self.view.layer insertSublayer:self.player.playerLayer atIndex:0];
        }
    }
    return self;
}

- (void)dealloc {
    [self.player remove];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _shouldAutorotate = YES;
    _supportedInterfaceOrientations = UIInterfaceOrientationMaskAllButUpsideDown;
    //
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGestureRecognizer:)];
    [self.view addGestureRecognizer:_panGestureRecognizer];
    _velocityOfSeeking = 1.f;
    _velocityOfVolume = 1.f;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //
    _player.playerLayer.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Orientation

- (BOOL)shouldAutorotate {
    return _shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return _supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
    if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
        orientation = UIInterfaceOrientationPortrait;
    } else if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
        orientation = UIInterfaceOrientationLandscapeLeft;
    } else if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
        orientation = UIInterfaceOrientationLandscapeRight;
    } else if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
        orientation = UIInterfaceOrientationPortraitUpsideDown;
    }
    //
    if (_shouldAutorotate) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
                    orientation = UIInterfaceOrientationPortrait;
                }
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown) {
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                }
                break;
            case UIDeviceOrientationLandscapeLeft:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
                    orientation = UIInterfaceOrientationLandscapeLeft;
                }
                break;
            case UIDeviceOrientationLandscapeRight:
                if (_supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
                    orientation = UIInterfaceOrientationLandscapeRight;
                }
                break;
            default:
                break;
        }
    }
    //
    return orientation;
}

#pragma mark Volume

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

- (void)onPanGestureRecognizer:(id)sender {
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
                seekTime = _player.currentTime;
            } else {
                volumeValue = _volumeSlider.value;
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [pan translationInView:pan.view];
            CGPoint offset = CGPointMake(point.x - startPoint.x, point.y - startPoint.y);
            if (isSeeking) {
                NSTimeInterval time = seekTime + (offset.x / (_velocityOfSeeking * 4));
                if (time < 0) {
                    time = 0;
                }
                if (time > _player.duration) {
                    time = _player.duration;
                }
                [_player seekToTime:time andPlay:pan.state == UIGestureRecognizerStateEnded];
            } else {
                _volumeSlider.value = volumeValue - (offset.y / (_velocityOfVolume * 80));
            }
            break;
        }

        default:
            break;
    }
}

@end

#pragma mark - UIApplication (ZXPlayerViewController)

@interface UIApplication (ZXPlayerViewController)

@end

@implementation UIApplication (ZXPlayerViewController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(supportedInterfaceOrientationsForWindow:) with:@selector(supportedInterfaceOrientationsForPlayerViewController:)];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForPlayerViewController:(nullable UIWindow *)window {
    if ([window.rootViewController.topmostViewController isKindOfClass:[ZXPlayerViewController class]]) {
        return window.rootViewController.topmostViewController.supportedInterfaceOrientations;
    }
    return [self supportedInterfaceOrientationsForPlayerViewController:window];
}

@end
