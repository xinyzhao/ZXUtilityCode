//
// ZXDownloadManager.h
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

#import "ZXDownloadTask.h"

/**
 ZXDownloadManager
 */
@interface ZXDownloadManager : NSObject

/**
 The shared instance of ZXDownloadManager

 @return ZXDownloadManager
 */
+ (instancetype _Nonnull)sharedManager;

/**
 Default directory where the downloaded files are saved.
 */
@property (nonatomic, copy, nonnull) NSString *localPath;

/**
 The count of maximum concurrent downloads, default is 0 which means no limit.
 */
@property (nonatomic, assign) NSInteger maximumConcurrentCount;

/**
 Break point resume enabled or not, maybe not work, default is YES
 */
@property (nonatomic, assign) BOOL breakpointResume;

/**
 Create or got exist download task with URL

 @param URL The URL
 @param path The save directory, Ignore saveInDirectory if setted.
 @param backgroundMode Downloads in the background or not.
 @return ZXDownloadTask
 */
- (ZXDownloadTask *_Nullable)downloadTaskWithURL:(NSURL *_Nonnull)URL;
- (ZXDownloadTask *_Nullable)downloadTaskWithURL:(NSURL *_Nonnull)URL inDirectory:(NSString *_Nullable)path inBackground:(BOOL)backgroundMode;

/**
 Suspend download for URL

 @param URL URL
 */
- (void)suspendDownloadForURL:(NSURL *_Nonnull)URL;

/**
 Suspend download task

 @param task The task
 */
- (void)suspendDownloadTask:(ZXDownloadTask *_Nonnull)task;

/**
 Suspend all downloads
 */
- (void)suspendAllDownloads;

/**
 Resume download for URL

 @param URL URL
 */
- (void)resumeDownloadForURL:(NSURL *_Nonnull)URL;

/**
 Resume the download task

 @param task The download task
 @return True resume success
 */
- (BOOL)resumeDownloadTask:(ZXDownloadTask *_Nonnull)task;

/**
 Resume all downloads
 */
- (void)resumeAllDownloads;

/**
 Cancel download for URL

 @param URL URL
 */
- (void)cancelDownloadForURL:(NSURL *_Nonnull)URL;

/**
 Cancel download task

 @param task The task
 */
- (void)cancelDownloadTask:(ZXDownloadTask *_Nonnull)task;

/**
 Cancel all downloads
 */
- (void)cancelAllDownloads;

@end
