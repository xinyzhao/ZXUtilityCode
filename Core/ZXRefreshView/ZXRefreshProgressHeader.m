//
// ZXRefreshProgressHeader.m
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

#import "ZXRefreshProgressHeader.h"

@implementation ZXRefreshProgressHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.circularRadius = 16;
        self.animationDuration = 0.8;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark Setter & Getter

- (void)setCircularRadius:(CGFloat)radius {
    _circularRadius = radius;
    //
    CGRect rect  = self.frame;
    rect.origin.x = rect.size.width / 2 - radius;
    rect.origin.y = rect.size.height / 2 - radius;
    rect.size = CGSizeMake(radius * 2, radius * 2);
    //
    if (self.progressView == nil) {
        self.progressView = [[ZXCircularProgressView alloc] initWithFrame:rect];
        [self addSubview:self.progressView];
    } else {
        self.progressView.frame = rect;
    }
    //
    [self updateContentSize];
}

#pragma mark Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    //
    CGPoint center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.progressView.center = center;
}

#pragma mark Animating

- (void)startAnimating {
    if (self.progressView.tag == 0) {
        self.progressView.tag = 1;
        [self.progressView.layer removeAllAnimations];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = [NSNumber numberWithDouble:M_PI * 2];
        animation.duration = _animationDuration;
        animation.cumulative = YES;
        animation.repeatCount = INT_MAX;
        animation.removedOnCompletion = NO;
        [self.progressView.layer addAnimation:animation forKey:@"transform.rotation.z"];
    }
}

- (void)stopAnimating {
    if (self.progressView.tag == 1) {
        [self.progressView.layer removeAllAnimations];
        self.progressView.tag = 0;
    }
}

#pragma mark <ZXRefreshProtocol>

- (void)setPullingProgress:(CGFloat)progress {
    [super setPullingProgress:progress];
    self.progressView.progress = progress;
}

- (BOOL)beginRefreshing {
    if ([super beginRefreshing]) {
        self.pullingProgress = 1.f;
        [self startAnimating];
        return YES;
    }
    return NO;
}

- (BOOL)endRefreshing {
    if ([super endRefreshing]) {
        [self stopAnimating];
        return YES;
    }
    return NO;
}

- (void)updateContentSize {
    [super updateContentSize];
    //
    self.contentOffset = (self.contentHeight + _circularRadius * 2) / 2;
}

@end

#pragma mark - ZXCircularProgressView

@implementation ZXCircularProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.integrity = 0.8;
        self.lineWidth = 1.5;
        self.progressColor = [UIColor orangeColor];
        self.progress = 0.f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // The rect is Wrong ?
    CGFloat progress = _progress > 1.f ? 1.f : _progress;
    //
    rect = self.bounds;
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2 - _lineWidth / 2;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = startAngle + M_PI * 2 * progress * _integrity;
    //
    if (_progress > 1.f) {
        progress = _progress - 1.f;
        startAngle += M_PI * 2 * progress * _integrity;
        endAngle += M_PI * 2 * progress * _integrity;
    }
    //
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:center
                          radius:radius
                      startAngle:startAngle
                        endAngle:endAngle
                       clockwise:YES];
    bezierPath.lineWidth = _lineWidth;
    [_progressColor setStroke];
    [bezierPath stroke];
}

- (void)setIntegrity:(CGFloat)integrity {
    _integrity = integrity;
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = [progressColor copy];
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0.f) {
        progress = 0.f;
    }
    _progress = progress;
    [self setNeedsDisplay];
}

@end
