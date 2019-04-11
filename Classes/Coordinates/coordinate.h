//
// coordinate.h
// https://github.com/xinyzhao/ZXUtilityCode
//
// Copyright (c) 2016 Zhao Xin. All rights reserved.
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

#ifndef coordinate_h
#define coordinate_h

#include <stdio.h>

// Earth radius
#define EARTH_RADIUS                6378245.f   //meters
#define EQUATORIAL_RADIUS           (EARTH_RADIUS / 1000.f) //kilometers

// Latitude & Longitude
#define latitudeOfKilometer         ((EQUATORIAL_RADIUS * M_PI) / 180.f)
#define latitudeOfMeters(m)         ((m / 1000.f) / latitudeOfKilometer)
#define longitudeOfMeters(m, lat)   (cos(lat) * latitudeOfMeters(m))

// Degrees to Radians
#define DEGREES_TO_RADIANS(d) ((d) * M_PI / 180)
// Radians to Degrees
#define RADIANS_TO_DEGREES(r) ((r) / M_PI * 180)

// BD-09 to GCJ-02
void coordinate_baidu_to_china(double in_lat, double in_lng, double *out_lat, double *out_lng);

// GCJ-02 to BD-09
void coordinate_china_to_baidu(double in_lat, double in_lng, double *out_lat, double *out_lng);

// GCJ-02 to WGS-84
void coordinate_china_to_world(double in_lat, double in_lng, double *out_lat, double *out_lng);

// WGS-84 to GCJ-02
void coordinate_world_to_china(double in_lat, double in_lng, double *out_lat, double *out_lng);

// Out of China
bool coordinate_outof_china(double lat, double lng);

// Distance
double coordinate_distance(double lat1, double lng1, double lat2, double lng2);

#endif /* coordinate_h */
