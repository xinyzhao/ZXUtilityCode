//
// JSONObject.h
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

/**
 * JSON 对象转换
 */
@interface JSONObject : NSObject

/**
 * @brief 判断是否为有效的 JSON 对象
 * @param obj JSON 对象
 * @return 成功返回 YES，失败返回 NO
 */
+ (BOOL)isValidJSONObject:(id)obj;

/**
 * @brief 获取 JSON 数据
 * @param obj JSON 对象
 * @return 成功返回 JSON 数据，失败返回 nil
 */
+ (NSData *)dataWithJSONObject:(id)obj;

/**
 * @brief 获取 JSON 格式字符串
 * @param obj JSON 对象
 * @return 成功返回 JSON 格式字符串，失败返回 nil
 */
+ (NSString *)stringWithJSONObject:(id)obj;

/**
 * @brief 从 JSON 数据中得到 JSON 对象
 * @param data JSON 数据
 * @return 成功返回 JSON 对象，失败返回 nil
 */
+ (id)JSONObjectWithData:(NSData *)data;

/**
 * @brief 从 JSON 字符串中得到 JSON 对象
 * @param string JSON 字符串
 * @return 成功返回 JSON 对象，失败返回nil
 */
+ (id)JSONObjectWithString:(NSString *)string;

@end
