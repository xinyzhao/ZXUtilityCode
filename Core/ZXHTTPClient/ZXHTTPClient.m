//
// ZXHTTPClient.m
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

#import "ZXHTTPClient.h"

@interface ZXHTTPClient ()

+ (NSURLSession *)URLSession;

@end

#pragma mark - ZXHTTPClient

@implementation ZXHTTPClient

+ (NSURLSession *)URLSession {
    static NSURLSession *_urlSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = nil;
        NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 1;
        _urlSession = [NSURLSession sessionWithConfiguration:configuration
                                                   delegate:[ZXHTTPClient securityPolicy]
                                              delegateQueue:operationQueue];
    });
    return _urlSession;
}

+ (ZXHTTPSecurity *)securityPolicy {
    static ZXHTTPSecurity *_securityPolicy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _securityPolicy = [[ZXHTTPSecurity alloc] init];
    });
    return _securityPolicy;
}

#pragma mark HTTP Request

+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers body:(NSData *)body success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    // parameters
    if (params.count > 0) {
        NSMutableArray *pairs = [[NSMutableArray alloc] init];
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", key, obj];
            [pairs addObject:pair];
        }];
        // query string
        NSString *query = [pairs componentsJoinedByString:@"&"];
        if (query) {
            URLString = [URLString stringByAppendingFormat:@"?%@", query];
        }
    }
    // URL request
    NSMutableURLRequest *reqeust = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    reqeust.HTTPMethod = method;
    reqeust.HTTPBody = body;
    // HTTP header fields
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [reqeust setValue:obj forHTTPHeaderField:key];
    }];
    // data task
    __block NSURLSessionDataTask *task = [[ZXHTTPClient URLSession] dataTaskWithRequest:reqeust completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(task, error);
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success(task, data);
                }
            });
        }
    }];
    [task resume];
    // return
    return task;
}

+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers formData:(NSArray<ZXHTTPFormData *> *)formData success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    // boundary
    static NSString *boundary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        boundary = [[NSUUID UUID] UUIDString];
    });
    // form data
    NSMutableData *bodyData = [NSMutableData data];
    [formData enumerateObjectsUsingBlock:^(ZXHTTPFormData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // new boundary
        NSString *newBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
        [bodyData appendData:[newBoundary dataUsingEncoding:NSUTF8StringEncoding]];
        // content disposition
        if (obj.fileName) {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", obj.name, obj.fileName];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", obj.name];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // content type
        if (obj.mimeType) {
            NSString *str = [NSString stringWithFormat:@"Content-Type: %@\r\n", obj.mimeType];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // content data
        [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        if (obj.data) {
            [bodyData appendData:obj.data];
        }
    }];
    // end boundary
    if (bodyData.length > 0) {
        NSString *endBoundary = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
        [bodyData appendData:[endBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    }
    // header fields
    NSMutableDictionary *headerFields = [headers mutableCopy];
    if (headerFields == nil) {
        headerFields = [[NSMutableDictionary alloc] init];
    }
    [headerFields setObject:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forKey:@"Content-Type"];
    [headerFields setObject:[NSString stringWithFormat:@"%zd", bodyData.length] forKey:@"Content-Length"];
    // HTTP request
    return [ZXHTTPClient requestWithURLString:URLString method:method params:params headers:headerFields body:bodyData success:success failure:failure];
}

+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers jsonObject:(id)jsonObject success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    // JSON data
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonObject options:kNilOptions error:&error];
    if (bodyData) {
        // header fields
        NSMutableDictionary *headerFields = [headers mutableCopy];
        if (headerFields == nil) {
            headerFields = [[NSMutableDictionary alloc] init];
        }
        [headerFields setObject:@"application/json; charset=utf-8" forKey:@"Content-Type"];
        [headerFields setObject:[NSString stringWithFormat:@"%zd", bodyData.length] forKey:@"Content-Length"];
        // HTTP request
        return [ZXHTTPClient requestWithURLString:URLString method:method params:params headers:headerFields body:bodyData success:success failure:failure];
    }
    // failure
    if (failure) {
        failure(nil, error);
    }
    return nil;
}

#pragma mark HTTP Methods

+ (NSURLSessionDataTask *)GET:(NSString *)URLString params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPClient requestWithURLString:URLString method:@"GET" params:params headers:nil body:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPClient requestWithURLString:URLString method:@"POST" params:params headers:nil formData:formData success:success failure:failure];
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params jsonObject:(id)jsonObject success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPClient requestWithURLString:URLString method:@"POST" params:params headers:nil jsonObject:jsonObject success:success failure:failure];
}

@end

#pragma mark - ZXHTTPFormData

@implementation ZXHTTPFormData

- (instancetype)initWithData:(NSData *)data name:(NSString *)name {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = name;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
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
