//
// NSURLSessionManager.m
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

#import "NSURLSessionManager.h"

@interface NSURLSessionManager ()
@property (nonatomic, strong) dispatch_queue_t taskQueue;

- (void)requestWithURL:(NSString *)url params:(NSDictionary *)params method:(NSString *)method headers:(NSDictionary *)headers body:(NSData *)body success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure;

@end

@implementation NSURLSessionManager

static NSURLSessionManager *_defaultManager = nil;

+ (NSURLSessionManager *)defaultManager {
    if (_defaultManager == nil) {
        _defaultManager = [[NSURLSessionManager alloc] init];
    }
    return _defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeoutInterval = 30.f;
        self.taskQueue = dispatch_queue_create("NSURLSessionManager", NULL);
    }
    return self;
}

#pragma mark HTTP Method

- (void)requestWithURL:(NSString *)url params:(NSDictionary *)params method:(NSString *)method headers:(NSDictionary *)headers body:(NSData *)body success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    //
    dispatch_async(self.taskQueue, ^{
        // url
        NSString *urlString = url;
        // params
        if (params.count > 0) {
            NSMutableArray *pairs = [[NSMutableArray alloc] init];
            [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *pair = [NSString stringWithFormat:@"%@=%@", key, obj];
                [pairs addObject:pair];
            }];
            // query
            NSString *query = [pairs componentsJoinedByString:@"&"];
            if (query) {
                urlString = [url stringByAppendingFormat:@"?%@", query];
            }
        }
        // request
        NSMutableURLRequest *reqeust = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        reqeust.HTTPMethod = method;
        reqeust.HTTPBody = body;
        reqeust.timeoutInterval = self.timeoutInterval;
        // header fields
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [reqeust setValue:obj forHTTPHeaderField:key];
        }];
        // task
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:reqeust completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@ %@\nRET %@(%d)", method, urlString, error.localizedDescription, (int)error.code);
                if (failure) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure((NSHTTPURLResponse *)response, error);
                    });
                }
            } else {
                id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                if (obj == nil) {
                    obj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                if (obj == nil) {
                    obj = [NSString stringWithFormat:@"<Unknown data, length: %d bytes>", (int)data.length];
                }
                NSLog(@"%@ %@\nRET %@", method, urlString, obj);
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success((NSHTTPURLResponse *)response, data);
                    });
                }
            }
        }];
        [task resume];
    });
}

- (void)getWithURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"GET" headers:headers body:nil success:success failure:failure];
}

- (void)postWithURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers body:(NSData *)body success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"POST" headers:headers body:body success:success failure:failure];
}

@end
