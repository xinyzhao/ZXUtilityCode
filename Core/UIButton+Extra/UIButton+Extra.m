//
// UIButton+Extra.m
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

#import "UIButton+Extra.h"
#import "NSObject+Extra.h"

@interface UIButton (_Extra)
@property (nonatomic, assign) NSTimeInterval acceptEventTime;
@property (nonatomic, assign) BOOL acceptEventDisabled;
@property (nonatomic, assign) BOOL acceptEventEnabled;

@end

@implementation UIButton (_Extra)

- (void)setAcceptEventTime:(NSTimeInterval)acceptEventTime {
    objc_setAssociatedObject(self, @selector(acceptEventTime), @(acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventTime {
    NSNumber *number = objc_getAssociatedObject(self, @selector(acceptEventTime));
    return number ? [number doubleValue] : 0.f;
}

- (void)setAcceptEventEnabled:(BOOL)acceptEventEnabled {
    objc_setAssociatedObject(self, @selector(acceptEventEnabled), @(acceptEventEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)acceptEventEnabled {
    NSNumber *number = objc_getAssociatedObject(self, @selector(acceptEventEnabled));
    return number ? [number boolValue] : NO;
}

- (void)setAcceptEventDisabled:(BOOL)acceptEventDisabled {
    objc_setAssociatedObject(self, @selector(acceptEventDisabled), @(acceptEventDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)acceptEventDisabled {
    NSNumber *number = objc_getAssociatedObject(self, @selector(acceptEventDisabled));
    return number ? [number boolValue] : NO;
}

@end

@implementation UIButton (Extra)

#pragma mark Methods hook

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            SEL originalSelector = @selector(sendAction:to:forEvent:);
            SEL swizzledSelector = @selector(extra_sendAction:to:forEvent:);
            [self swizzleMethod:originalSelector with:swizzledSelector];
        }
        {
            SEL originalSelector = @selector(setEnabled:);
            SEL swizzledSelector = @selector(extra_setEnabled:);
            [self swizzleMethod:originalSelector with:swizzledSelector];
        }
    });
}

- (void)extra_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    if (time - self.acceptEventTime < self.acceptEventInterval) {
        return;
    }
    if (self.acceptEventInterval > 0.f) {
        self.acceptEventTime = time;
        self.acceptEventEnabled = self.enabled;
        self.acceptEventDisabled = YES;
        [self extra_setEnabled:NO];
        //
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.acceptEventInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.acceptEventDisabled = NO;
            weakSelf.enabled = weakSelf.acceptEventEnabled;
        });
    }
    [self extra_sendAction:action to:target forEvent:event];
}

- (void)extra_setEnabled:(BOOL)enabled {
    if (self.acceptEventDisabled) {
        self.acceptEventEnabled = enabled;
    }
    [self extra_setEnabled:enabled];
}

#pragma mark Setter & Getter

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval {
    objc_setAssociatedObject(self, @selector(acceptEventInterval), @(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventInterval {
    NSNumber *number = objc_getAssociatedObject(self, @selector(acceptEventInterval));
    return number ? [number doubleValue] : 0.f;
}

#pragma mark Functions

- (void)setForceRightToLeft:(CGFloat)spacing forState:(UIControlState)state {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        NSString *title = [self titleForState:state];
        UIImage *image = [self imageForState:state];
        if (title && image) {
            [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width - spacing / 2, 0, image.size.width)];
            CGSize labelSize = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
            [self setImageEdgeInsets:UIEdgeInsetsMake(0, labelSize.width, 0, -labelSize.width - spacing / 2)];
        }
    } else {
        self.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -spacing / 2, 0, 0)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -spacing / 2)];
    }
}

@end
