//
// UIButton+Extra.m
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

#import "UIButton+Extra.h"

@implementation UIButton (Extra)

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
