//
// NSString+HashValue.m
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

#import "NSString+HashValue.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HashValue)

- (NSData *)MD5Data {
    const char *data = [self UTF8String];
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG)strlen(data), bytes);
    return [NSData dataWithBytes:bytes length:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)MD5String {
    const char *data = [self UTF8String];
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG)strlen(data), bytes);
    //
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [string appendFormat:@"%02x", bytes[i]];
    }
    return string;
}

- (NSData *)SHA1Data {
    const char *data = [self UTF8String];
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data, (CC_LONG)strlen(data), bytes);
    return [NSData dataWithBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)SHA1String {
    const char *data = [self UTF8String];
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data, (CC_LONG)strlen(data), bytes);
    //
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [string appendFormat:@"%02x", bytes[i]];
    }
    return string;
}

@end
