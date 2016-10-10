//
// ZXColorPickerCell.m
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

#import "ZXColorPickerCell.h"

@interface ZXColorPickerCell () <UITextFieldDelegate>

@end

@implementation ZXColorPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.textSlider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (BOOL)checkValue {
    if (self.isHexValue) {
        NSRange range = [self.textField.text rangeOfString:@"^[0-9a-fA-F]{6,8}$" options:NSRegularExpressionSearch];
        return (range.location != NSNotFound);
    } else if (self.isPercentValue) {
        NSRange range = [self.textField.text rangeOfString:@"^[0-9]{1,3}\%?$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return self.textField.text.floatValue <= self.textSlider.maximumValue;
        }
    } else {
        NSRange range = [self.textField.text rangeOfString:@"^[0-9]{1,3}$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return self.textField.text.floatValue <= self.textSlider.maximumValue;
        }
    }
    return NO;
}

- (NSString *)sliderValue {
    if (self.isPercentValue) {
        return [NSString stringWithFormat:@"%.f%%", self.textSlider.value];
    } else {
        return [NSString stringWithFormat:@"%.f", self.textSlider.value];
    }
}

- (CGFloat)textValue {
    if ([self checkValue]) {
        return [self.textField.text floatValue];
    }
    return self.textSlider.value;
}

#pragma mark Target Actions

- (IBAction)onValueChanged:(id)sender {
    if (sender == self.textSlider) {
        self.textField.text = [self sliderValue];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    } else if (sender == self.textField) {
        if ([self checkValue]) {
            self.textSlider.value = [self textValue];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

#pragma mark <UITextFieldDelegate>
   
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return [self checkValue];
}

@end
