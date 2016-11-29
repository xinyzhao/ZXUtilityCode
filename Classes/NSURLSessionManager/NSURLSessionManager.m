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

- (void)deleteWithURL:(NSString *)url params:(NSDictionary *)params success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"DELETE" headers:nil body:nil success:success failure:failure];
}

- (void)headWithURL:(NSString *)url params:(NSDictionary *)params success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"HEAD" headers:nil body:nil success:success failure:failure];
}

- (void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"GET" headers:nil body:nil success:success failure:failure];
}

- (void)postWithURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers body:(NSData *)body success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"POST" headers:headers body:body success:success failure:failure];
}

- (void)postWithURL:(NSString *)url params:(NSDictionary *)params formData:(NSArray<NSMultipartFormData *> *)formData success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    // boundary
    NSString *boundary = [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
    // body
    NSMutableData *body = [NSMutableData data];
    [formData enumerateObjectsUsingBlock:^(NSMultipartFormData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if (obj.fileName) {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", obj.name, obj.fileName];
            [body appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", obj.name];
            [body appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        if (obj.mimeType) {
            NSString *str = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", obj.mimeType];
            [body appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        if (obj.data) {
            [body appendData:obj.data];
        }
    }];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // request
    NSDictionary *headers = @{@"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary],
                              @"Content-Length":[NSString stringWithFormat:@"%zd", body.length]};
    [self postWithURL:url params:params headers:headers body:body success:success failure:failure];
}

- (void)postWithURL:(NSString *)url params:(NSDictionary *)params jsonObject:(id)jsonObject success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        NSError *error;
        NSData *body = [NSJSONSerialization dataWithJSONObject:jsonObject options:kNilOptions error:&error];
        if (body) {
            NSDictionary *headers = @{@"Content-Type":@"Content-Type",
                                      @"Content-Length":[NSString stringWithFormat:@"%zd", body.length]};
            [self postWithURL:url params:params headers:headers body:body success:success failure:failure];
        } else if (failure && error) {
            failure(nil, error);
        }
    } else if (failure) {
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON Object"}];
        failure(nil, error);
    }
}

- (void)putWithURL:(NSString *)url params:(NSDictionary *)params success:(NSURLSessionSuccessBlock)success failure:(NSURLSessionFailureBlock)failure {
    [self requestWithURL:url params:params method:@"PUT" headers:nil body:nil success:success failure:failure];
}

@end


@implementation NSMultipartFormData

- (instancetype)initWithData:(NSData *)data name:(NSData *)name {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = name;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data name:(NSData *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = name;
        self.fileName = fileName;
        self.mimeType = mimeType;
    }
    return self;
}

@end
