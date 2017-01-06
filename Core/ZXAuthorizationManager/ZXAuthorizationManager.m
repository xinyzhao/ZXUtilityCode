//
// ZXAuthorizationManager.m
//
// Copyright (c) 2017 Zhao Xin. All rights reserved.
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

#import "ZXAuthorizationManager.h"

typedef void(^CLAuthorizationHandler)(CLAuthorizationStatus status);

@interface ZXAuthorizationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) CLAuthorizationHandler locationHandler;

+ (instancetype)defaultManager;

@end

@implementation ZXAuthorizationManager

+ (instancetype)defaultManager {
    static ZXAuthorizationManager *authManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authManager = [[ZXAuthorizationManager alloc] init];
    });
    return authManager;
}

+ (void)authorizationForCamera:(void(^)(AVAuthorizationStatus status))handler {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (handler) {
                    handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
                }
            }];
        } else if (handler) {
            handler(status);
        }
    }
}

+ (void)authorizationForContacts:(void(^)(AVAuthorizationStatus status))handler {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 9.0) {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            CFRelease(addressBook);
            if (handler) {
                handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
            }
        });
    } else {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *__nullable error) {
                if (handler) {
                    handler(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
                }
            }];
        } else if (handler) {
            handler((NSInteger)status);
        }
    }
}

+ (void)authorizationForLocation:(BOOL)always handler:(void(^)(CLAuthorizationStatus status))handler {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status == kCLAuthorizationStatusNotDetermined) {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                ZXAuthorizationManager *manager = [ZXAuthorizationManager defaultManager];
                if (manager.locationManager == nil) {
                    manager.locationManager = [[CLLocationManager alloc] init];
                }
                manager.locationManager.delegate = manager;
                manager.locationHandler = handler;
                //
                if (always) {
                    [manager.locationManager requestAlwaysAuthorization];
                } else {
                    [manager.locationManager requestWhenInUseAuthorization];
                }
            }
        } else if (handler) {
            handler(status);
        }
    }
}

+ (void)authorizationForMicrophone:(void(^)(BOOL granted))handler {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (handler) {
                handler(granted);
            }
        }];
    }
}

+ (void)authorizationForPhotoLibrary:(void(^)(NSInteger status))handler {
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        if (handler) {
            handler(status);
        }
    } else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) {
                        handler(status);
                    }
                });
            }];
        } else if (handler) {
           handler(status);
        }
    }
}

#pragma mark <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (self.locationHandler) {
        self.locationHandler(status);
    }
}

@end