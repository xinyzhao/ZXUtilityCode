//
// UINetworkActivityIndicator.m
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

#import "UINetworkActivityIndicator.h"

@implementation UINetworkActivityIndicator

/// 网络活动数量，大于0则显示网络指示器，等于0则隐藏指示器
static NSInteger __networkActivityCount = 0;

+ (void)showNetworkActivityIndicator {
    __networkActivityCount++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = __networkActivityCount > 0;
}

+ (void)hideNetworkActivityIndicator {
    if (__networkActivityCount > 0) {
        __networkActivityCount--;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = __networkActivityCount > 0;
    }
}

@end
