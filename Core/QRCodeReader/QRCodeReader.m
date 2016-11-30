//
// QRCodeReader.m
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

#import "QRCodeReader.h"

@implementation QRCodeReader

+ (NSArray *)decodeQRCodeImage:(UIImage *)image {
    NSMutableArray *results = [NSMutableArray array];
    //
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.f) {
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        [features enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CIQRCodeFeature *feature = obj;
            NSString *str = feature.messageString;
            if (str) {
                [results addObject:str];
            }
        }];
    } else {
        NSLog(@"%s Your system version is lower than 8.0!", __func__);
    }
    //
    return results.count > 0 ? results : nil;
}

@end
