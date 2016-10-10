//
// ZXColorPickerController.m
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

#import "ZXColorPickerController.h"
#import "ZXColorPickerCell.h"

@interface ZXColorPickerController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;

@property (weak, nonatomic) IBOutlet UIView *rgbView;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *redCell;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *greenCell;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *blueCell;

@property (weak, nonatomic) IBOutlet UIView *hsbView;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *hueCell;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *saturationCell;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *brightnessCell;

@property (weak, nonatomic) IBOutlet ZXColorPickerCell *opacityCell;
@property (weak, nonatomic) IBOutlet ZXColorPickerCell *hexCell;
@property (weak, nonatomic) IBOutlet UILabel *hexLabel;

@property (nonatomic, setter=setRGBColor:) UIColor *rgbColor;
@property (nonatomic, setter=setHSBColor:) UIColor *hsbColor;
@property (nonatomic, setter=setHEXColor:) UIColor *hexColor;
@property (nonatomic, assign) CGFloat opacity;

@end

@implementation ZXColorPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //
    self.saturationCell.isPercentValue = YES;
    self.brightnessCell.isPercentValue = YES;
    self.opacityCell.isPercentValue = YES;
    //
    self.hexCell.isHexValue = YES;
    self.hexCell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.hexCell.imageView.layer.borderWidth = .5;
    self.hexCell.imageView.layer.cornerRadius = 5;
    self.hexCell.imageView.layer.masksToBounds = YES;
    self.hexCell.textField.leftView = self.hexLabel;
    self.hexCell.textField.leftViewMode = UITextFieldViewModeAlways;
    //
    if (self.currentColor == nil) {
        self.currentColor = [UIColor whiteColor];
    } else {
        self.currentColor = _currentColor;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //
    self.navigationItem.titleView = self.segmentedControl;
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
}

#pragma mark Proerties

- (void)setCurrentColor:(UIColor *)currentColor {
    _currentColor = [currentColor copy];
    //
    self.rgbColor = _currentColor;
    self.hsbColor = _currentColor;
    self.hexColor = _currentColor;
    self.opacity = _currentColor.alpha;
    //
    self.hexCell.imageView.backgroundColor = _currentColor;
}

- (void)setRGBColor:(UIColor *)color {
    _redCell.textSlider.value = color.red * 255.f;
    _redCell.textField.text = [NSString stringWithFormat:@"%.f", _redCell.textSlider.value];
    _greenCell.textSlider.value = color.green * 255.f;
    _greenCell.textField.text = [NSString stringWithFormat:@"%.f", _greenCell.textSlider.value];
    _blueCell.textSlider.value = color.blue * 255.f;
    _blueCell.textField.text = [NSString stringWithFormat:@"%.f", _blueCell.textSlider.value];
}

- (UIColor *)rgbColor {
    CGFloat r = self.redCell.textSlider.value / 255.f;
    CGFloat g = self.greenCell.textSlider.value / 255.f;
    CGFloat b = self.blueCell.textSlider.value / 255.f;
    CGFloat a = self.opacity;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)setHSBColor:(UIColor *)color {
    _hueCell.textSlider.value = color.hue * 360.f;
    _hueCell.textField.text = [NSString stringWithFormat:@"%.f", _hueCell.textSlider.value];
    _saturationCell.textSlider.value = color.saturation * 100.f;
    _saturationCell.textField.text = [NSString stringWithFormat:@"%.f%%", _saturationCell.textSlider.value];
    _brightnessCell.textSlider.value = color.brightness * 100.f;
    _brightnessCell.textField.text = [NSString stringWithFormat:@"%.f%%", _brightnessCell.textSlider.value];
}

- (UIColor *)hsbColor {
    CGFloat h = self.hueCell.textSlider.value / 360.f;
    CGFloat s = self.saturationCell.textSlider.value / 100.f;
    CGFloat b = self.brightnessCell.textSlider.value / 100.f;
    CGFloat a = self.opacity;
    return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
}

- (void)setHEXColor:(UIColor *)color {
    _hexCell.textField.text = color.hexString;
    _hexCell.imageView.backgroundColor = color;
}

- (UIColor *)hexColor {
    UIColor *color = [UIColor colorWithHexString:self.hexCell.textField.text];
    return [color colorWithAlphaComponent:self.opacity];
}

- (void)setOpacity:(CGFloat)opacity {
    _opacityCell.textSlider.value = opacity * 100.f;
    _opacityCell.textField.text = [NSString stringWithFormat:@"%.f%%", _opacityCell.textSlider.value];
}

- (CGFloat)opacity {
    return _opacityCell.textSlider.value / 100.f;
}

#pragma mark Target Actions

- (IBAction)onCancel:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onDone:(id)sender {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (_completionBlock) {
        _completionBlock(_currentColor);
    }
}

- (IBAction)onType:(id)sender {
    self.rgbView.hidden = self.segmentedControl.selectedSegmentIndex == 1;
    self.hsbView.hidden = self.segmentedControl.selectedSegmentIndex == 0;
}

- (IBAction)onValueChanged:(id)sender {
    if (sender == self.redCell ||
        sender == self.greenCell ||
        sender == self.blueCell) {
        //
        _currentColor = self.rgbColor;
        self.hsbColor = _currentColor;
        self.hexColor = _currentColor;
        
    } else if (sender == self.hueCell ||
               sender == self.saturationCell ||
               sender == self.brightnessCell) {
        //
        _currentColor = self.hsbColor;
        self.rgbColor = _currentColor;
        self.hexColor = _currentColor;
        
    } else if (sender == self.opacityCell) {
        //
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            _currentColor = self.rgbColor;
        } else {
            _currentColor = self.hsbColor;
        }
        self.hexColor = _currentColor;
        
    } else if (sender == self.hexCell) {
        //
        _currentColor = self.hexColor;
        self.rgbColor = _currentColor;
        self.hsbColor = _currentColor;
        self.opacity = _currentColor.alpha;
        self.hexCell.imageView.backgroundColor = _currentColor;
        
    }
}

@end
