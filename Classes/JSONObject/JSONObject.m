//
// JSONObject.m
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

#import "JSONObject.h"

@implementation JSONObject

+ (BOOL)isValidJSONObject:(id)obj {
    return [NSJSONSerialization isValidJSONObject:obj];
}

+ (NSData *)dataWithJSONObject:(id)obj {
    NSData *data = nil;
    if ([JSONObject isValidJSONObject:obj]) {
        NSError *error;
        data = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:&error];
        if (data == nil) {
            NSLog(@"dataWithJSONObject failed with error: %@", error.localizedDescription);
        }
    }
    return data;
}

+ (NSString *)stringWithJSONObject:(id)obj {
    NSData *jsonData = [JSONObject dataWithJSONObject:obj];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (id)JSONObjectWithData:(NSData *)data {
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (object == nil) {
        NSLog(@"JSONObjectWithData failed with error: %@", error.localizedDescription);
    }
    return object;
}

+ (id)JSONObjectWithString:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [JSONObject JSONObjectWithData:data];
}

@end
