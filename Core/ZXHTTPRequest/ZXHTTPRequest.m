//
// ZXHTTPRequest.m
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

#import "ZXHTTPRequest.h"

@interface ZXHTTPRequest ()

+ (NSURLSessionDataTask *)requestWithURL:(NSString *)url params:(NSDictionary *)params method:(NSString *)method headers:(NSDictionary *)headers body:(NSData *)body success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers body:(NSData *)body success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

@end

#pragma mark - ZXHTTPRequest

@implementation ZXHTTPRequest

+ (NSURLSessionDataTask *)requestWithURL:(NSString *)url params:(NSDictionary *)params method:(NSString *)method headers:(NSDictionary *)headers body:(NSData *)body success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
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
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure((NSHTTPURLResponse *)response, error);
                }
            });
        } else {
            id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (obj == nil) {
                obj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            if (obj == nil) {
                obj = [NSString stringWithFormat:@"<Unknown data, length: %d bytes>", (int)data.length];
            }
            NSLog(@"%@ %@\nRET %@", method, urlString, obj);
            //
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    success((NSHTTPURLResponse *)response, data);
                }
            });
        }
    }];
    [task resume];
    // return
    return task;
}

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params headers:(NSDictionary *)headers body:(NSData *)body success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPRequest requestWithURL:url params:params method:@"POST" headers:headers body:body success:success failure:failure];
}

#pragma mark Public

+ (NSURLSessionDataTask *)deleteWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPRequest requestWithURL:url params:params method:@"DELETE" headers:nil body:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)headWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPRequest requestWithURL:url params:params method:@"HEAD" headers:nil body:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)getWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPRequest requestWithURL:url params:params method:@"GET" headers:nil body:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPRequest postWithURL:url params:params headers:nil body:nil success:success failure:failure];
}

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    // boundary
    NSString *boundary = [[NSUUID UUID] UUIDString];
    // body
    NSMutableData *bodyData = [NSMutableData data];
    [formData enumerateObjectsUsingBlock:^(ZXHTTPFormData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if (obj.fileName) {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", obj.name, obj.fileName];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", obj.name];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        }
        if (obj.mimeType) {
            NSString *str = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", obj.mimeType];
            [bodyData appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        if (obj.data) {
            [bodyData appendData:obj.data];
        }
    }];
    [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // request
    NSDictionary *headers = @{@"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary],
                              @"Content-Length":[NSString stringWithFormat:@"%zd", bodyData.length]};
    return [ZXHTTPRequest postWithURL:url params:params headers:headers body:bodyData success:success failure:failure];
}

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params jsonObject:(id)jsonObject success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    NSError *error;
    //
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonObject options:kNilOptions error:&error];
        if (bodyData) {
            NSDictionary *headers = @{@"Content-Type":@"application/json",
                                      @"Content-Length":[NSString stringWithFormat:@"%zd", bodyData.length]};
            return [ZXHTTPRequest postWithURL:url params:params headers:headers body:bodyData success:success failure:failure];
        }
    } else {
        error = [NSError errorWithDomain:NSStringFromClass([self class])
                                    code:-1
                                userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON Object"}];
    }
    //
    if (failure) {
        failure(nil, error);
    }
    return nil;
}

+ (NSURLSessionDataTask *)putWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure {
    return [ZXHTTPRequest requestWithURL:url params:params method:@"PUT" headers:nil body:nil success:success failure:failure];
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
