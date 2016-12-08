//
// ZXHTTPClient.h
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

@class ZXHTTPFormData;

/**
 HTTP request success handler
 
 @param task A NSURLSessionDataTask object
 @param data The response data
 */
typedef void (^ZXHTTPRequestSuccess)(NSURLSessionDataTask *task, NSData *data);

/**
 HTTP request failure handler
 
 @param task A NSURLSessionDataTask object
 @param error Request error occurs
 */
typedef void (^ZXHTTPRequestFailure)(NSURLSessionDataTask *task, NSError *error);

/**
 ZXHTTPClient
 */
@interface ZXHTTPClient : NSObject

#pragma mark HTTP request

/**
 HTTP Request

 @param URLString The request URL string
 @param method The HTTP method
 @param params The query string with key value pairs
 @param headers The HTTP header fields
 @param body The HTTP body data
 @param success Request success handler
 @param failure Request failure handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers body:(NSData *)body success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

/**
 HTTP Request with "multipart/form-data"
 
 @param URLString The request URL string
 @param method The HTTP method
 @param params The query string with key value pairs
 @param headers The HTTP header fields
 @param formData The form data for HTTP body
 @param success Request success handler
 @param failure Request failure handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers formData:(NSArray<ZXHTTPFormData *> *)formData success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

/**
 HTTP Request with "application/json"
 
 @param URLString The request URL string
 @param method The HTTP method
 @param params The query string with key value pairs
 @param headers The HTTP header fields
 @param jsonObject The JSON object for HTTP body
 @param success Request success handler
 @param failure Request failure handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)requestWithURLString:(NSString *)URLString method:(NSString *)method params:(NSDictionary *)params headers:(NSDictionary *)headers jsonObject:(id)jsonObject success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

#pragma mark HTTP methods

/**
 HTTP Request with GET method
 
 @param URLString The request URL string
 @param params The query string with key value pairs
 @param success Request success handler
 @param failure Request failure handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString params:(NSDictionary *)params success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

/**
 HTTP Request with POST method
 
 @param URLString The request URL string
 @param params The query string with key value pairs
 @param formData The form data for HTTP body
 @param success Request success handler
 @param failure Request failure handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params formData:(NSArray<ZXHTTPFormData *> *)formData success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

/**
 HTTP Request with POST method
 
 @param URLString The request URL string
 @param params The query string with key value pairs
 @param jsonObject The JSON object for HTTP body
 @param success Request success handler
 @param failure Request failure handler
 @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString params:(NSDictionary *)params jsonObject:(id)jsonObject success:(ZXHTTPRequestSuccess)success failure:(ZXHTTPRequestFailure)failure;

@end

/**
 ZXHTTPFormData
 */
@interface ZXHTTPFormData : NSObject
/**
 Required, The form data
 */
@property (nonatomic, strong) NSData *data;
/**
 Required, Name for data
 */
@property (nonatomic, strong) NSString *name;
/**
 Optional, File name for data
 */
@property (nonatomic, strong) NSString *fileName;
/**
 Optional, MIME type for data
 */
@property (nonatomic, strong) NSString *mimeType;

/**
 Initializes with data
 
 @param data The form data
 @param name Name for data
 @return Instance
 */
- (instancetype)initWithData:(NSData *)data name:(NSString *)name;

/**
 Initializes with file
 
 @param data The form data
 @param name Name for data
 @param fileName File name for data
 @param mimeType MIME type for data
 @return Instance
 */
- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end
