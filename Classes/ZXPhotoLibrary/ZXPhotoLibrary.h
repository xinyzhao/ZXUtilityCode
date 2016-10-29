//
// ZXPhotoLibrary.h
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

#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>

@class ZXPhotoGroup;
@class ZXPhotoAsset;

/// ZXPhotoLibraryChangedNotification
UIKIT_EXTERN NSString *const ZXPhotoLibraryChangedNotification;

/// ZXAuthorizationStatus
typedef NS_ENUM(NSInteger, ZXAuthorizationStatus) {
    ZXAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    ZXAuthorizationStatusRestricted,        // This application is not authorized to access photo data.
                                            // The user cannot change this application’s status, possibly due to active restrictions
                                            //   such as parental controls being in place.
    ZXAuthorizationStatusDenied,            // User has explicitly denied this application access to photos data.
    ZXAuthorizationStatusAuthorized         // User has authorized this application to access photos data.
} NS_AVAILABLE_IOS(7_0);

/// ZXAssetMediaType
typedef NS_ENUM(NSInteger, ZXAssetMediaType) {
    ZXAssetMediaTypeUnknown = 0,
    ZXAssetMediaTypeImage   = 1,
    ZXAssetMediaTypeVideo   = 2,
    ZXAssetMediaTypeAudio   = 3,
} NS_ENUM_AVAILABLE_IOS(7_0);

/// ZXImageContentMode
typedef NS_ENUM(NSInteger, ZXImageContentMode) {
    ZXImageContentModeAspectFit = 0,
    ZXImageContentModeAspectFill = 1,
    ZXImageContentModeDefault = ZXImageContentModeAspectFit
} NS_ENUM_AVAILABLE_IOS(7_0);

/// ZXPhotoLibrary
@interface ZXPhotoLibrary : NSObject

+ (ZXPhotoLibrary *)defaultLibrary;

- (void)requestAuthorization:(void(^)(ZXAuthorizationStatus status))completion;
- (void)fetchGroupsWithEmptyAlbum:(BOOL)emptyAlbum completion:(void(^)(NSArray<ZXPhotoGroup *> *results))completion;
- (void)fetchAssetsWithAscending:(BOOL)ascending completion:(void(^)(NSArray<ZXPhotoAsset *> *results))completion;

@end

/// ZXPhotoGroup
@interface ZXPhotoGroup : NSObject
@property (nonatomic, assign, readonly) NSString *groupName;
@property (nonatomic, assign, readonly) UIImage *posterImage;
@property (nonatomic, assign, readonly) NSUInteger numberOfAssets;

- (NSUInteger)numberOfAssetsWithMediaType:(ZXAssetMediaType)mediaType;
- (void)fetchAssetsWithAscending:(BOOL)ascending completion:(void(^)(NSArray<ZXPhotoAsset *> *results))completion;

@end

/// ZXPhotoAsset
@interface ZXPhotoAsset : NSObject
@property (nonatomic, assign, readonly) ZXAssetMediaType mediaType;
@property (nonatomic, assign, readonly) CGSize mediaSize;
@property (nonatomic, assign, readonly) NSUInteger numberOfBytes;
@property (nonatomic, assign, readonly) UIImageOrientation orientation;

- (NSData *)imageData;
- (UIImage *)imageForAspectFill:(BOOL)aspectFill targetSize:(CGSize)targetSize;

@end
