//
// ZXDownloadTask.m
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
#import "NSString+HashValue.h"

@interface ZXDownloadTaskObserver : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) void(^state)(ZXDownloadTaskState state);
@property (nonatomic, copy) void(^progress)(int64_t receivedSize, int64_t expectedSize, CGFloat progress);
@property (nonatomic, copy) void(^completion)(BOOL completed, NSString *filePath, NSError *error);

@end

@implementation ZXDownloadTaskObserver

@end

@interface ZXDownloadTask ()
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *tempPath;

@end

@implementation ZXDownloadTask

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL localPath:nil backgroundMode:NO];
}

- (instancetype)initWithURL:(NSURL *)URL localPath:(NSString *)path backgroundMode:(BOOL)backgroundMode {
    self = [super init];
    if (self) {
        self.taskURL = URL;
        self.taskIdentifier = [URL.absoluteString SHA1String];
        self.backgroundMode = backgroundMode;
        self.observers = [[NSMutableDictionary alloc] init];
        //
        _taskState = 0;
        _totalBytesWritten = 0;
        _totalBytesExpectedToWrite = 0;
        //
        BOOL isDirectory = NO;
        if (path == nil) {
            path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        }
        BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
        if (!isExists || !isDirectory) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        //
        self.filePath = [path stringByAppendingPathComponent:[URL lastPathComponent]];
        self.tempPath = [path stringByAppendingPathComponent:self.taskIdentifier];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            self.taskState = ZXDownloadTaskStateCompleted;
        } else {
            self.totalBytesWritten = [self fileSizeAtPath:self.tempPath];
            self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempPath append:YES];
        }
    }
    return self;
}

- (void)addObserver:(NSObject *)observer
              state:(void(^)(ZXDownloadTaskState state))state
           progress:(void(^)(int64_t receivedSize, int64_t expectedSize, CGFloat progress))progress
         completion:(void(^)(BOOL completed, NSString *filePath, NSError *error))completion {
    ZXDownloadTaskObserver *taskObserver = [[ZXDownloadTaskObserver alloc] init];
    taskObserver.observer = observer;
    taskObserver.state = state;
    taskObserver.progress = progress;
    taskObserver.completion = completion;
    [self.observers setObject:taskObserver forKey:@(observer.hash)];
}

- (void)removeObserver:(NSObject *)observer {
    [self.observers removeObjectForKey:@(observer.hash)];
}

#pragma mark Files

- (uint64_t)fileSizeAtPath:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (attributes) {
            return [attributes[NSFileSize] longLongValue];
        }
    }
    return 0;
}

#pragma mark Properties

- (void)setTaskState:(ZXDownloadTaskState)taskState {
    _taskState = taskState;
    //
    switch (_taskState) {
        case ZXDownloadTaskStateUnknown:
            return;

        case ZXDownloadTaskStateRunning:
            [self.dataTask resume];
            break;
            
        case ZXDownloadTaskStateSuspended:
            [self.dataTask suspend];
            break;
            
        case ZXDownloadTaskStateCancelled:
            [self.outputStream close];
            [self.dataTask cancel];
            break;
            
        case ZXDownloadTaskStateCompleted:
            [self.outputStream close];
            break;
            
        default:
            break;
    }
    NSArray *observers = [self.observers allValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadTaskObserver *observer in observers) {
            if (observer.state) {
                observer.state(_taskState);
            }
        }
    });
}

- (void)setTotalBytesWritten:(int64_t)totalBytesWritten {
    _totalBytesWritten = totalBytesWritten;
    if (_totalBytesExpectedToWrite > 0) {
        self.progress = (float)_totalBytesWritten / _totalBytesExpectedToWrite;
    } else {
        self.progress = 0.f;
    }
}

- (void)setTotalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    if (_totalBytesExpectedToWrite > 0) {
        self.progress = (float)_totalBytesWritten / _totalBytesExpectedToWrite;
    } else {
        self.progress = 0.f;
    }
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    //
    NSArray *observers = [self.observers allValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadTaskObserver *observer in observers) {
            if (observer.progress) {
                observer.progress(_totalBytesWritten, _totalBytesExpectedToWrite, _progress);
            }
        }
    });
}

#pragma mark <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    BOOL completed = NO;
    NSString *filePath = nil;
    if (self.totalBytesWritten == self.totalBytesExpectedToWrite) {
        self.taskState = ZXDownloadTaskStateCompleted;
        completed = YES;
        filePath = self.filePath;
        //
        [[NSFileManager defaultManager] moveItemAtPath:self.tempPath
                                                toPath:self.filePath
                                                 error:(error == nil ? &error : nil)];
    }
    //
    NSArray *observers = [self.observers allValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadTaskObserver *observer in observers) {
            if (observer.completion) {
                observer.completion(completed, filePath, error);
            }
        }
    });
}

@end
