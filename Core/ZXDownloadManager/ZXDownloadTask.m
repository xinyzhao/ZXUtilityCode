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

@interface ZXDownloadObserver : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) void(^state)(ZXDownloadState state);
@property (nonatomic, copy) void(^progress)(int64_t receivedSize, int64_t expectedSize, CGFloat progress);
@property (nonatomic, copy) void(^completion)(BOOL completed, NSString *localFilePath, NSError *error);

@end

@implementation ZXDownloadObserver

@end

@interface ZXDownloadTask ()
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) NSString *streamFilePath;
@property (nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation ZXDownloadTask

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithURL:URL localPath:nil backgroundMode:NO];
}

- (instancetype)initWithURL:(NSURL *)URL localPath:(NSString *)path backgroundMode:(BOOL)backgroundMode {
    self = [super init];
    if (self) {
        _observers = [[NSMutableDictionary alloc] init];
        _taskURL = [URL copy];
        _taskIdentifier = [URL.absoluteString SHA1String];
        _backgroundMode = backgroundMode;
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
        _state = ZXDownloadStateUnknown;
        _totalBytesWritten = 0;
        _totalBytesExpectedToWrite = 0;
        _localFilePath = [path stringByAppendingPathComponent:[URL lastPathComponent]];
        _streamFilePath = [path stringByAppendingPathComponent:_taskIdentifier];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_localFilePath]) {
            self.state = ZXDownloadStateCompleted;
        } else {
            self.totalBytesWritten = [self fileSizeAtPath:_streamFilePath];
        }
    }
    return self;
}

- (void)addObserver:(NSObject *)observer
              state:(void(^)(ZXDownloadState state))state
           progress:(void(^)(int64_t receivedSize, int64_t expectedSize, CGFloat progress))progress
         completion:(void(^)(BOOL completed, NSString *filePath, NSError *error))completion {
    ZXDownloadObserver *taskObserver = [[ZXDownloadObserver alloc] init];
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

- (void)setState:(ZXDownloadState)state {
    _state = state;
    //
    switch (_state) {
        case ZXDownloadStateUnknown:
            return;

        case ZXDownloadStateRunning:
            [self.dataTask resume];
            break;
            
        case ZXDownloadStateSuspended:
            [self.dataTask suspend];
            break;
            
        case ZXDownloadStateCancelled:
            [self.dataTask cancel];
            [self closeOutputStream];
            break;
            
        case ZXDownloadStateCompleted:
            [self closeOutputStream];
            break;
            
        default:
            break;
    }
    //
    NSArray *observers = [self.observers allValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (ZXDownloadObserver *observer in observers) {
            if (observer.state) {
                observer.state(_state);
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
        for (ZXDownloadObserver *observer in observers) {
            if (observer.progress) {
                observer.progress(_totalBytesWritten, _totalBytesExpectedToWrite, _progress);
            }
        }
    });
}

#pragma mark Output Stream

- (void)openOutputStreamWithAppend:(BOOL)append {
    _outputStream = [NSOutputStream outputStreamToFileAtPath:_streamFilePath append:append];
    [_outputStream open];
}

- (void)closeOutputStream {
    if (_outputStream) {
        if (_outputStream.streamStatus > NSStreamStatusNotOpen && _outputStream.streamStatus < NSStreamStatusClosed) {
            [_outputStream close];
        }
        _outputStream = nil;
    }
}

#pragma mark <NSURLSessionDataDelegate>

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    //
    BOOL append = NO;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
        append = http.statusCode == 206;
    }
    //
    _totalBytesExpectedToWrite = response.expectedContentLength;
    if (append) {
        _totalBytesExpectedToWrite += _totalBytesWritten;
    }
    //
    [self openOutputStreamWithAppend:append];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (data) {
        [_outputStream write:data.bytes maxLength:data.length];
        self.totalBytesWritten += (int64_t)data.length;
    }
}

#pragma mark <NSURLSessionTaskDelegate>

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (self.totalBytesWritten == self.totalBytesExpectedToWrite) {
        [[NSFileManager defaultManager] moveItemAtPath:_streamFilePath
                                                toPath:_localFilePath
                                                 error:(error == nil ? &error : nil)];
        self.state = ZXDownloadStateCompleted;
    }
    //
    NSArray *observers = [self.observers allValues];
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL completed = _state == ZXDownloadStateCompleted;
        NSString *path = completed ? _localFilePath : nil;
        for (ZXDownloadObserver *observer in observers) {
            if (observer.completion) {
                observer.completion(completed, path, error);
            }
        }
    });
}

@end
