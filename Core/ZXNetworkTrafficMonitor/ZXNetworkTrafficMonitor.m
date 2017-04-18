//
// ZXNetworkTrafficMonitor.m
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

#import "ZXNetworkTrafficMonitor.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>


@interface ZXNetworkTrafficMonitor ()
@property (nonatomic, copy) ZXNetworkTrafficBlock trafficBlock;
@property (nonatomic, strong) NSTimer *trafficTimer;
@property (nonatomic, assign) NSUInteger trafficTimes;

@property (nonatomic, assign) NSUInteger WiFiSent;
@property (nonatomic, assign) NSUInteger WiFiReceived;
@property (nonatomic, assign) NSUInteger WWANSent;
@property (nonatomic, assign) NSUInteger WWANReceived;

@end

@implementation ZXNetworkTrafficMonitor

- (void)startMonitoring:(NSTimeInterval)timeInterval trafficBlock:(ZXNetworkTrafficBlock)trafficBlock {
    if (!self.isMonitoring) {
        _trafficBlock = [trafficBlock copy];
        _trafficTimes = 0;
        //
        self.trafficTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.trafficTimer forMode:NSRunLoopCommonModes];
        [self.trafficTimer fire];
    }
}

- (BOOL)isMonitoring {
    return [self.trafficTimer isValid];
}

- (void)stopMonitoring {
    if ([self.trafficTimer isValid]) {
        [self.trafficTimer invalidate];
    }
    self.trafficTimer = nil;
    self.trafficBlock = nil;
}

- (void)onTimer:(id)sender {
    NSDictionary *dict = [self trafficData];
    
    NSUInteger WiFiSent = [dict[@"WiFiSent"] unsignedIntValue];
    NSUInteger WiFiReceived = [dict[@"WiFiReceived"] unsignedIntValue];
    NSUInteger WWANSent = [dict[@"WWANSent"] unsignedIntValue];
    NSUInteger WWANReceived = [dict[@"WWANReceived"] unsignedIntValue];
    
    if (_trafficTimes > 0) {
        WiFiSent -= _WiFiSent;
        WiFiReceived -= _WiFiReceived;
        WWANSent -= _WWANSent;
        WWANReceived -= _WWANReceived;
        
        if (_trafficBlock) {
            _trafficBlock(WiFiSent, WiFiReceived, WWANSent, WWANReceived);
        }
    }
    
    _trafficTimes++;
    _WiFiSent = [dict[@"WiFiSent"] unsignedIntValue];
    _WiFiReceived = [dict[@"WiFiReceived"] unsignedIntValue];
    _WWANSent = [dict[@"WWANSent"] unsignedIntValue];
    _WWANReceived = [dict[@"WWANReceived"] unsignedIntValue];
}

/**
 Reference http://stackoverflow.com/questions/7946699/iphone-data-usage-tracking-monitoring
 */
- (NSDictionary *)trafficData {
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    
    u_int32_t WiFiSent = 0;
    u_int32_t WiFiReceived = 0;
    u_int32_t WWANSent = 0;
    u_int32_t WWANReceived = 0;
    
    if (getifaddrs(&addrs) == 0) {
        cursor = addrs;
        while (cursor != NULL) {
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                // name of interfaces:
                // en0 is WiFi
                // pdp_ip0 is WWAN
                NSString *name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
                if ([name hasPrefix:@"en"])
                {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WiFiSent += ifa_data->ifi_obytes;
                        WiFiReceived += ifa_data->ifi_ibytes;
                    }
                }
                
                if ([name hasPrefix:@"pdp_ip"]) {
                    const struct if_data *ifa_data = (struct if_data *)cursor->ifa_data;
                    if(ifa_data != NULL)
                    {
                        WWANSent += ifa_data->ifi_obytes;
                        WWANReceived += ifa_data->ifi_ibytes;
                    }
                }
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return @{@"WiFiSent":@(WiFiSent),
             @"WiFiReceived":@(WiFiReceived),
             @"WWANSent":@(WWANSent),
             @"WWANReceived":@(WWANReceived)};
}

@end
