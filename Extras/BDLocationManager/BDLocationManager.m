//
// BDLocationManager.m
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

#import "BDLocationManager.h"
#import "coordinate.h"
#import "BDGeocoder.h"
#import <MapKit/MapKit.h>

NSString *const BDLocationManagerDidUpdateLocationNotification = @"BDLocationManagerDidUpdateLocationNotification";

@interface BDLocationManager () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic, strong) CLLocationManager<Ignore> *manager;
@property (nonatomic, strong) MKMapView<Ignore> *mapView;

@end

@implementation BDLocationManager

+ (BDLocationManager *)defaultManager {
    static BDLocationManager *_defaultManager = nil;
    if (_defaultManager == nil) {
        _defaultManager = [[[self class] alloc] init];
    }
    return _defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        [self loadLocation];
        //
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        //
        [self startLocationService];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopLocationService];
}

#pragma mark - UIApplication Status

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self startUpdatingLocation];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self stopUpdatingLocation];
}

#pragma mark - Location Services

- (void)startLocationService {
    // locationServicesEnabled
    if ([CLLocationManager locationServicesEnabled]) {
        if (self.manager == nil) {
            self.manager = [[CLLocationManager alloc] init];
            self.manager.delegate = self;
            self.manager.desiredAccuracy = kCLLocationAccuracyBest;
            self.manager.distanceFilter = 100.f;
        }
        if (self.mapView == nil) {
            self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(-1, -1, 1, 1)];
            self.mapView.delegate = self;
            self.mapView.userTrackingMode = MKUserTrackingModeNone;
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.mapView];
        }
        // requestWhenInUseAuthorization
        if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.manager requestWhenInUseAuthorization];
        } else {
            [self startUpdatingLocation];
        }
    }
}

- (void)stopLocationService {
    //
    [self stopUpdatingLocation];
    //
    if (self.manager) {
        self.manager = nil;
    }
    if (self.mapView) {
        [self.mapView removeFromSuperview];
        self.mapView = nil;
    }
}

- (void)startUpdatingLocation {
    if (self.mapView) {
        [self.mapView setShowsUserLocation:YES];
    } else {
        [self.manager startUpdatingLocation];
    }
}

- (void)stopUpdatingLocation {
    if (self.mapView) {
        [self.mapView setShowsUserLocation:NO];
    } else {
        [self.manager stopUpdatingLocation];
    }
}

#pragma mark Synchronize

- (void)loadLocation {
    NSString *file = [NSFileManager cachesFile:@"location.data" inDirectory:[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]];
    NSData *data = [NSData dataWithContentsOfFile:file];
    if (data) {
        NSError *error;
        self.location = [[BDLocation alloc] initWithData:data error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    //
    if (self.location == nil) {
        self.location = [[BDLocation alloc] init];
        self.location.latitude = 40.01461667653867;
        self.location.longitude = 116.4927348362845;
    }
}

- (void)saveLocation {
    NSString *file = [NSFileManager cachesFile:@"location.data" inDirectory:[NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"]];
    [self.location.toJSONData writeToFile:file atomically:YES];
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    // once
    [self stopUpdatingLocation];
    // location
    CLLocation *location = [locations firstObject];
    self.location = [[BDLocation alloc] init];
    self.location.latitude = location.coordinate.latitude;
    self.location.longitude = location.coordinate.longitude;
    // geocoder
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error){
        CLPlacemark *placemark = [array firstObject];
        if (placemark) {
            self.location = [[BDLocation alloc] init];
            self.location.name = placemark.name;
            self.location.city = placemark.locality ? placemark.locality : placemark.administrativeArea;
            self.location.country = placemark.country;
            self.location.countryCode = placemark.ISOcountryCode;
            self.location.district = placemark.subAdministrativeArea;
            self.location.province = placemark.administrativeArea;
            self.location.street = placemark.thoroughfare;
            self.location.streetNumber = placemark.subThoroughfare;
            self.location.latitude = placemark.location.coordinate.latitude;
            self.location.longitude = placemark.location.coordinate.longitude;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        // notification
        [self postLocationNotification];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.manager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            // tips ?
        default:
            [self startUpdatingLocation];
            break;
    }
}

#pragma mark - <MKMapViewDelegate>

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    //
    [self stopUpdatingLocation];
    // convert
    double lat = userLocation.coordinate.latitude;
    double lng = userLocation.coordinate.longitude;
    coordinate_china_to_baidu(lat, lng, &lat, &lng);
    //
    self.location = [[BDLocation alloc] init];
    self.location.latitude = lat;
    self.location.longitude = lng;
    // geocoder
    [[[BDGeocoder alloc] init] reverseGeocodeLocation:self.location completion:^(NSArray<BDLocation *> *locations, NSError *error) {
        if (locations.count > 0) {
            self.location = [locations firstObject];
        }
        // notification
        [self postLocationNotification];
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"%s>>>%@", __func__, error.localizedDescription);
}

#pragma mark - Post Notification

- (void)postLocationNotification {
    if (self.location) {
        // synchronize
        [self saveLocation];
        // notification
        NSDictionary *userInfo = @{@"location":self.location};
        [[NSNotificationCenter defaultCenter] postNotificationName:BDLocationManagerDidUpdateLocationNotification object:self userInfo:userInfo];
    }
}

@end
