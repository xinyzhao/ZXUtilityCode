//
// QRCodeScanner.m
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


#import "QRCodeScanner.h"

@interface QRCodeScanner () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, copy)   QRCodeScannerOutput outputBlock;

@end

@implementation QRCodeScanner

- (instancetype)initWithPreview:(UIView *)preview captureRect:(CGRect)frame {
    self = [super init];
    if (self) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        //
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        [_session addInput:_input];
        //
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_session addOutput:_output];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_output setMetadataObjectTypes:_output.availableMetadataObjectTypes];
        //
        if (preview) {
            _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
            _preview.frame = preview.layer.bounds;
            [preview.layer insertSublayer:_preview atIndex:0];
            // top-left to top-right coordinate system (Rotate 90° CCW), the origin is the central point
            _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            CGRect rect = CGRectMake(((preview.frame.size.height - frame.size.height) / 2) / preview.frame.size.height,
                                     ((preview.frame.size.width - frame.size.width) / 2) / preview.frame.size.width,
                                     frame.size.height / _preview.frame.size.height,
                                     frame.size.width / _preview.frame.size.width);
            _output.rectOfInterest = rect;
        }
    }
    return self;
}

#pragma mark Scanning

- (void)startScanning:(QRCodeScannerOutput)output {
    self.outputBlock = output;
    [_session startRunning];
}

- (void)stopScanning {
    [_session stopRunning];
}

- (BOOL)isScanning {
    return _session.isRunning;
}

#pragma mark AVCaptureTorchMode

- (void)setTorchMode:(AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    }
}

- (AVCaptureTorchMode)torchMode {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return device.torchMode;
}

#pragma mark <AVCaptureMetadataOutputObjectsDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //
    NSMutableArray<NSString *> *results = [NSMutableArray array];
    [metadataObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            AVMetadataMachineReadableCodeObject *codeObj = obj;
            if (codeObj.stringValue) {
                [results addObject:codeObj.stringValue];
            }
        }
    }];
    //
    if (_outputBlock && results.count > 0) {
        _outputBlock(results);
    }
}

@end
