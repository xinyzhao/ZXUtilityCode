//
// ZXDownloadTask.h
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

#import <Foundation/Foundation.h>

/**
 ZXDownloadTaskState
 */
typedef NS_ENUM(NSInteger, ZXDownloadTaskState) {
    ZXDownloadTaskStateUnknown,
    ZXDownloadTaskStateWaiting,
    ZXDownloadTaskStateRunning,
    ZXDownloadTaskStateSuspended,
    ZXDownloadTaskStateCancelled,
    ZXDownloadTaskStateCompleted,
};

/**
 ZXDownloadTask
 */
@interface ZXDownloadTask : NSObject <NSURLSessionTaskDelegate>

/**
 The URL of this task
 */
@property (nonatomic, copy, nonnull) NSURL *taskURL;

/**
 Identifier for this task
 */
@property (nonatomic, copy, nonnull) NSString *taskIdentifier;

/**
 The local file path for this task
 */
@property (nonatomic, copy, nonnull) NSString *filePath;

/**
 The download task in the backgournd or not
 */
@property (nonatomic, assign) BOOL backgroundMode;

/**
 The current state of the task
 */
@property (nonatomic, assign) ZXDownloadTaskState taskState;

/**
 The download data task
 */
@property (nonatomic, strong, nullable) NSURLSessionDataTask *dataTask;

/**
 Write datas to the file
 */
@property (nonatomic, strong, nullable) NSOutputStream *outputStream;

/**
 Total bytes written
 */
@property (nonatomic, assign) int64_t totalBytesWritten;

/**
 Total bytes expected to write
 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

/**
 Init with URL

 @param URL The URL of download
 @return ZXDownloadTask
 */
- (instancetype _Nonnull)initWithURL:(NSURL *_Nonnull)URL;

/**
 Init with URL, save path and background mode

 @param URL The URL of download
 @param localPath The local path of download
 @param backgroundMode The background mode
 @return ZXDownloadTask
 */
- (instancetype _Nonnull)initWithURL:(NSURL *_Nonnull)URL localPath:(NSString *_Nullable)localPath backgroundMode:(BOOL)backgroundMode;

/**
 Add observer

 @param observer The observer
 @param state A block object to be executed when the download state changed.
 @param progress A block object to be executed when the download progress changed.
 @param completion A block object to be executed when the download completion.
 */
- (void)addObserver:(NSObject *_Nonnull)observer
              state:(void(^_Nullable)(ZXDownloadTaskState state))state
           progress:(void(^_Nullable)(int64_t receivedSize, int64_t expectedSize, CGFloat progress))progress
         completion:(void(^_Nullable)(BOOL completed, NSString *_Nullable filePath, NSError *_Nullable error))completion;

/**
 Remove observer

 @param observer The observer
 */
- (void)removeObserver:(NSObject *_Nonnull)observer;

@end
