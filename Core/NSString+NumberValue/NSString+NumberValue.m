//
// NSString+NumberValue.m
//
// Copyright (c) 2017 Zhao Xin. All rights reserved.
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

#import "NSString+NumberValue.h"

@implementation NSString (NumberValue)

- (NSNumberFormatter *)numberFormatter {
    __block NSNumberFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSNumberFormatter alloc] init];
    });
    return formatter;
}

- (char)charValue {
    return [[[self numberFormatter] numberFromString:self] charValue];
}

- (unsigned char)unsignedCharValue {
    return [[[self numberFormatter] numberFromString:self] unsignedCharValue];
}

- (short)shortValue {
    return [[[self numberFormatter] numberFromString:self] shortValue];
}

- (unsigned short)unsignedShortValue {
    return [[[self numberFormatter] numberFromString:self] unsignedShortValue];
}

- (unsigned int)unsignedIntValue {
    return [[[self numberFormatter] numberFromString:self] unsignedIntValue];
}

- (long)longValue {
    return [[[self numberFormatter] numberFromString:self] longValue];
}

- (unsigned long)unsignedLongValue {
    return [[[self numberFormatter] numberFromString:self] unsignedLongValue];
}

- (unsigned long long)unsignedLongLongValue {
    return [[[self numberFormatter] numberFromString:self] unsignedLongLongValue];
}

- (NSUInteger)unsignedIntegerValue {
    return [[[self numberFormatter] numberFromString:self] unsignedIntegerValue];
}

@end
