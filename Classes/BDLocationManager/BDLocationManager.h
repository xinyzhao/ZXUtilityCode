//
// BDLocationManager.h
// https://github.com/xinyzhao/ZXUtilityCode
//
// Copyright (c) 2016 Zhao Xin. All rights reserved.
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

#import "BDLocation.h"

// BDLocationManager
@interface BDLocationManager : NSObject

// 位置信息
@property (nonatomic, strong) BDLocation *location;

// 单例
+ (BDLocationManager *)defaultManager;

// 定位服务
- (void)startLocationService;
- (void)stopLocationService;

// 更新位置
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end

/**
 * @brief 位置更新通知
 * @param notification.userInfo = {@"location":BDLocation}
 */
extern NSString *const BDLocationManagerDidUpdateLocationNotification;
