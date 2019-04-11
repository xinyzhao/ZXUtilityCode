//
// BDLocation.h
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

#import <JSONModel/JSONModel.h>
#import <CoreLocation/CoreLocation.h>

@interface BDLocation : JSONModel
@property (nonatomic, strong) NSString<Optional> *address; // 地址
@property (nonatomic, strong) NSString<Optional> *name; // 名称
@property (nonatomic, strong) NSString<Optional> *city; // 城市
@property (nonatomic, strong) NSString<Optional> *cityCode; // 城市编码
@property (nonatomic, strong) NSString<Optional> *country; // 国家
@property (nonatomic, strong) NSString<Optional> *countryCode; // 国家编码
@property (nonatomic, strong) NSString<Optional> *district; // 地区
@property (nonatomic, strong) NSString<Optional> *province; // 省份
@property (nonatomic, strong) NSString<Optional> *street; // 街道
@property (nonatomic, strong) NSString<Optional> *streetNumber; // 街道编号
@property (nonatomic, assign) CLLocationDegrees latitude; // 纬度
@property (nonatomic, assign) CLLocationDegrees longitude; // 经度

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
                       longitude:(CLLocationDegrees)longitude;

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
                       longitude:(CLLocationDegrees)longitude
                         address:(NSString *)address
                            name:(NSString *)name;

// 获取地址名称
- (NSString *)addressName;

// 获取经纬度坐标
- (CLLocationCoordinate2D)coordinate;

@end
