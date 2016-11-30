//
// ZXHTTPRequest.h
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

#import <Foundation/Foundation.h>

typedef void (^ZXHTTPRequestSuccess)(NSHTTPURLResponse *response, NSData *data);
typedef void (^ZXHTTPRequestFailure)(NSHTTPURLResponse *response, NSError *error);

@class ZXHTTPFormData;

@interface ZXHTTPRequest : NSObject

+ (NSURLSessionDataTask *)deleteWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)headWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)getWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)postWithURL:(NSString *)url params:(NSDictionary *)params jsonObject:(id)jsonObject success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

+ (NSURLSessionDataTask *)putWithURL:(NSString *)url params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

@end

@interface ZXHTTPFormData : NSObject
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *mimeType;

- (instancetype)initWithData:(NSData *)data name:(NSString *)name;
- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end
