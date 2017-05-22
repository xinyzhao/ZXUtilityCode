//
// ZXDownloadManager.m
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

#import "ZXDownloadManager.h"
#import "NSString+HashValue.h"

@interface ZXDownloadManager () <NSURLSessionDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, strong) NSMutableDictionary *downloadTasks;

@end

@implementation ZXDownloadManager

+ (instancetype)sharedManager {
    static ZXDownloadManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[ZXDownloadManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:self
                                                delegateQueue:[[NSOperationQueue alloc] init]];
        NSURLSessionConfiguration *backgroundConfiguration = nil;
        if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
            backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:[[NSBundle mainBundle] bundleIdentifier]];
        } else {
            backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
        }
        self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfiguration
                                                               delegate:self
                                                          delegateQueue:nil];
        self.downloadTasks = [[NSMutableDictionary alloc] init];
        self.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:NSStringFromClass([self class])];
        self.maximumConcurrentCount = 0;
        self.breakpointResume = YES;
    }
    return self;
}

- (ZXDownloadTask *)downloadTaskWithURL:(NSURL *)URL {
    return [self downloadTaskWithURL:URL inDirectory:self.localPath inBackground:NO];
}

- (ZXDownloadTask *)downloadTaskWithURL:(NSURL *)URL inDirectory:(NSString *)path inBackground:(BOOL)backgroundMode {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    if (task == nil) {
        task = [[ZXDownloadTask alloc] initWithURL:URL localPath:(path ? path : self.localPath) backgroundMode:backgroundMode];
        if (task.taskState != ZXDownloadTaskStateCompleted) {
            // Range
            // bytes=x-y ==  x byte ~ y byte
            // bytes=x-  ==  x byte ~ end
            // bytes=-y  ==  head ~ y byte
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            if (self.breakpointResume) {
                [request setValue:[NSString stringWithFormat:@"bytes=%lld-", task.totalBytesWritten] forHTTPHeaderField:@"Range"];
            }
            task.dataTask = [self.session dataTaskWithRequest:request];
            //
            [self.downloadTasks setObject:task forKey:task.taskIdentifier];
        }
    }
    return task;
}

- (ZXDownloadTask *)downloadTaskForURL:(NSURL *)URL {
    NSString *taskIdentifier = [URL.absoluteString SHA1String];
    return [self.downloadTasks objectForKey:taskIdentifier];
}

#pragma mark Suspend

- (void)suspendDownloadForURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    [self suspendDownloadTask:task];
}

- (void)suspendDownloadTask:(ZXDownloadTask *)task {
    if (task) {
        task.taskState = ZXDownloadTaskStateSuspended;
        [self resumeNextDowloadTask];
    }
}

- (void)suspendAllDownloads {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        task.taskState = ZXDownloadTaskStateSuspended;
    }
}

#pragma mark Resume

- (BOOL)resumeDownloadTask:(ZXDownloadTask *)task {
    if (task.taskState == ZXDownloadTaskStateRunning ||
        task.taskState == ZXDownloadTaskStateCancelled ||
        task.taskState == ZXDownloadTaskStateCompleted) {
        return NO;
    }
    //
    if (self.maximumConcurrentCount > 0) {
        __block NSUInteger count = 0;
        [self.downloadTasks enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            ZXDownloadTask *task = obj;
            if (task.taskState == ZXDownloadTaskStateRunning) {
                ++count;
            }
        }];
        if (count >= self.maximumConcurrentCount) {
            if (task.taskState == ZXDownloadTaskStateSuspended) {
                task.taskState = ZXDownloadTaskStateWaiting;
            }
            return NO;
        }
    }
    //
    if (task) {
        task.taskState = ZXDownloadTaskStateRunning;
    }
    //
    return YES;
}

- (void)resumeNextDowloadTask {
    if (self.maximumConcurrentCount == 0) { // no limit so no waiting for download models
        return;
    }
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        if (task.taskState == ZXDownloadTaskStateWaiting) {
            [self resumeDownloadTask:task];
            break;
        }
    }
}

- (void)resumeDownloadForURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    if (task) {
        [self resumeDownloadTask:task];
    }
}

- (void)resumeAllDownloads {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        if (task.taskState == ZXDownloadTaskStateSuspended) {
            [self resumeDownloadTask:task];
        }
    }
}

#pragma mark Cancel

- (void)cancelDownloadForURL:(NSURL *)URL {
    ZXDownloadTask *task = [self downloadTaskForURL:URL];
    [self cancelDownloadTask:task];
}

- (void)cancelDownloadTask:(ZXDownloadTask *)task {
    if (task) {
        task.taskState = ZXDownloadTaskStateCancelled;
        [self.downloadTasks removeObjectForKey:task.taskIdentifier];
        [self resumeNextDowloadTask];
    }
}

- (void)cancelAllDownloads {
    for (ZXDownloadTask *task in [self.downloadTasks allValues]) {
        task.taskState = ZXDownloadTaskStateCancelled;
    }
    [self.downloadTasks removeAllObjects];
}

#pragma mark <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    ZXDownloadTask *task = [self downloadTaskForURL:dataTask.originalRequest.URL];
    if (task) {
        [task.outputStream open];
        task.totalBytesExpectedToWrite = response.expectedContentLength + task.totalBytesWritten;
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    ZXDownloadTask *task = [self downloadTaskForURL:dataTask.originalRequest.URL];
    if (task) {
        [task.outputStream write:data.bytes maxLength:data.length];
        task.totalBytesWritten += (int64_t)data.length;
    }
}

#pragma mark <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled) {
        return;
    }
    ZXDownloadTask *obj = [self downloadTaskForURL:task.originalRequest.URL];
    if (obj) {
        if ([obj respondsToSelector:@selector(URLSession:task:didCompleteWithError:)]) {
            [obj URLSession:session task:task didCompleteWithError:error];
        }
        [self resumeNextDowloadTask];
    }
}

#pragma makr <NSURLSessionDownloadDelegate>

/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLogA(@"%@", location.absoluteString);
//    ZXDownloadTask *task = [self downloadTaskForURL:downloadTask.originalRequest.URL];
}

/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLogA(@">>>%lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLogA(@">>>%lld/%lld", fileOffset, expectedTotalBytes);
}

#pragma mark - Background download

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    // Check if all download tasks have been finished.
//    [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
//        if ([downloadTasks count] == 0) {
//            if (self.backgroundTransferCompletionHandler != nil) {
//                // Copy locally the completion handler.
//                void(^completionHandler)() = self.backgroundTransferCompletionHandler;
//                
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    // Call the completion handler to tell the system that there are no other background transfers.
//                    completionHandler();
//                    
//                    // Show a local notification when all downloads are over.
//                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//                    localNotification.alertBody = @"All files have been downloaded!";
//                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//                }];
//                
//                // Make nil the backgroundTransferCompletionHandler.
//                self.backgroundTransferCompletionHandler = nil;
//            }
//        }
//    }];
}

@end
