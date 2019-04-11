//
// BDLocation.m
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

@implementation BDLocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.latitude = kCLLocationCoordinate2DInvalid.latitude;
        self.longitude = kCLLocationCoordinate2DInvalid.longitude;
    }
    return self;
}

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
                       longitude:(CLLocationDegrees)longitude {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude
                       longitude:(CLLocationDegrees)longitude
                         address:(NSString *)address
                            name:(NSString *)name {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.address = address;
        self.name = name;
    }
    return self;
}

- (NSString *)addressName {
    if (self.name.length > 0) {
        return self.name;
    }
    if (self.address.length > 0) {
        return self.address;
    }
    return nil;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(_latitude, _longitude);
}

@end
