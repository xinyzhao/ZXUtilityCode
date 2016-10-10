//
// AMRPlayer.m
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

#import "AMRPlayer.h"
#import "amrFileCodec.h"

@interface AMRPlayer ()
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;

@end

@implementation AMRPlayer

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
    }
    return self;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)prepareToPlay:(void(^)(AVAudioPlayer *player, NSError *error))completion {
    [self prepareToPlay:^(AVAudioPlayer *player) {
        if (completion) {
            completion(player, nil);
        }
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)prepareToPlay:(void(^)(AVAudioPlayer *player))success failure:(void(^)(NSError *error))failure {
    if (_data) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *wavData = DecodeAMRToWAVE(_data);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = nil;
                self.player = [[AVAudioPlayer alloc] initWithData:wavData error:&error];
                if (error) {
                    if (failure) {
                        failure(error);
                    }
                } else {
                    if (success) {
                        success(_player);
                    }
                }
            });
        });
    } else if (_url.isFileURL) {
        self.data = [NSData dataWithContentsOfURL:_url];
        [self prepareToPlay:success failure:failure];
    } else if (_url) {
        NSString *file = [NSTemporaryDirectory() stringByAppendingPathComponent:[_url lastPathComponent]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            self.data = [NSData dataWithContentsOfFile:file];
            [self prepareToPlay:success failure:failure];
        } else {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSError *error;
                weakSelf.data = [NSData dataWithContentsOfURL:_url options:0 error:&error];
                if (error) {
                    if (failure) {
                        failure(error);
                    }
                } else {
                    [weakSelf.data writeToFile:file atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self prepareToPlay:success failure:failure];
                    });
                }
            });
        }
    }
}

@end
