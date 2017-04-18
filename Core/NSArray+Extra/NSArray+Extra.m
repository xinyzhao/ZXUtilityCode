//
// NSArray+Extra.m
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

#import "NSArray+Extra.h"
#import <objc/runtime.h>

@implementation NSArray (Extra)

+ (void)load {
    Class class = objc_getClass("__NSArrayI");
    Method originalMethod = class_getInstanceMethod(class, @selector(objectAtIndex:));
    Method exchangeMethod = class_getInstanceMethod(class, @selector(objectByIndex:));
    method_exchangeImplementations(originalMethod, exchangeMethod);
}

- (id)objectByIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex:index];
    }
    return nil;
}

@end

@implementation NSMutableArray (Extra)

+ (void)load {
    Class class = objc_getClass("__NSArrayM");
    Method originalMethod = class_getInstanceMethod(class, @selector(objectAtIndex:));
    Method exchangeMethod = class_getInstanceMethod(class, @selector(objectByIndex:));
    method_exchangeImplementations(originalMethod, exchangeMethod);
}

- (id)objectByIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectByIndex:index];
    }
    return nil;
}

@end
