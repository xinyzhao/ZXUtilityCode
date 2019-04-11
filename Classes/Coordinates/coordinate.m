//
// coordinate.c
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

#include "coordinate.h"

#include <math.h>

const double X_PI = M_PI * 3000.0 / 180.0;

void coordinate_baidu_to_china(double in_lat, double in_lng, double *out_lat, double *out_lng)
{
    double x = in_lng - 0.0065, y = in_lat - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * X_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * X_PI);
    *out_lng = z * cos(theta);
    *out_lat = z * sin(theta);
}

void coordinate_china_to_baidu(double in_lat, double in_lng, double *out_lat, double *out_lng)
{
    double x = in_lng, y = in_lat;
    double z = sqrt(x * x + y * y) + 0.00002 * sin(y * X_PI);
    double theta = atan2(y, x) + 0.000003 * cos(x * X_PI);
    *out_lng = z * cos(theta) + 0.0065;
    *out_lat = z * sin(theta) + 0.006;
}

void coordinate_china_to_world(double in_lat, double in_lng, double *out_lat, double *out_lng)
{
    if (coordinate_outof_china(in_lat, in_lng)) {
        *out_lat = in_lat;
        *out_lng = in_lng;
    }
}

const double ee = 0.00669342162296594323;

static double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}

void coordinate_world_to_china(double in_lat, double in_lng, double *out_lat, double *out_lng)
{
    if (coordinate_outof_china(in_lat, in_lng))
    {
        *out_lat = in_lat;
        *out_lng = in_lng;
        return;
    }
    double lat = transformLat(in_lng - 105.0, in_lat - 35.0);
    double lng = transformLon(in_lng - 105.0, in_lat - 35.0);
    double radLat = in_lat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    lat = (lat * 180.0) / ((EARTH_RADIUS * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    lng = (lng * 180.0) / (EARTH_RADIUS / sqrtMagic * cos(radLat) * M_PI);
    *out_lat = in_lat + lat;
    *out_lng = in_lng + lng;
}

bool coordinate_outof_china(double lat, double lng) {
    if (lng < 72.004 || lng > 137.8347)
        return true;
    if (lat < 0.8293 || lat > 55.8271)
        return true;
    return false;
}

double coordinate_distance(double lat1, double lng1, double lat2, double lng2)
{
    double radLat1 = DEGREES_TO_RADIANS(lat1);
    double radLat2 = DEGREES_TO_RADIANS(lat2);
    double a = radLat1 - radLat2;
    double b = DEGREES_TO_RADIANS(lng1) - DEGREES_TO_RADIANS(lng2);
    double s = sqrt(pow(sin(a / 2) ,2) + cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2));
    s = sin(s) * 2;
    s = s * EQUATORIAL_RADIUS;
    s = round(s * 10000) / 10000;
    return s;
}
