//
// NSDate+Extra.m
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

#import "NSDate+Extra.h"

NSString *const NSDateExtraFormatDatetime   = @"yyyy-MM-dd HH:mm:ss";
NSString *const NSDateExtraFormatDate       = @"yyyy-MM-dd";
NSString *const NSDateExtraFormatTime       = @"HH:mm:ss";

@implementation NSDate (Extra)

static NSCalendar *_currentCalendar = nil;
static NSCache *_dateFormatterCache = nil;

+ (NSCalendar *)currentCalendar {
    if (_currentCalendar == nil) {
        _currentCalendar = [NSCalendar currentCalendar];
    }
    return _currentCalendar;
}

+ (NSDateFormatter *)dateFormatterForDateFormat:(NSString *)dateFormat {
    if (_dateFormatterCache == nil) {
        _dateFormatterCache = [[NSCache alloc] init];
    }
    NSDateFormatter *dateFormatter = nil;
    if (dateFormat) {
        dateFormatter = [_dateFormatterCache objectForKey:dateFormat];
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en"]];
            [dateFormatter setDateFormat:dateFormat];
            [_dateFormatterCache setObject:dateFormatter forKey:dateFormat];
        }
    }
    return dateFormatter;
}

+ (NSDate *)dateWithString:(NSString *)string format:(NSString *)format {
    NSString *key = format ? format : NSDateExtraFormatDatetime;
    NSDateFormatter *dateFormatter = [NSDate dateFormatterForDateFormat:key];
    return [dateFormatter dateFromString:string];
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSString *key = format ? format : NSDateExtraFormatDatetime;
    NSDateFormatter *dateFormatter = [NSDate dateFormatterForDateFormat:key];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dateString {
    return [self stringWithFormat:NSDateExtraFormatDate];
}

- (NSString *)datetimeString {
    return [self stringWithFormat:NSDateExtraFormatDatetime];
}

- (NSString *)timeString {
    return [self stringWithFormat:NSDateExtraFormatTime];
}

- (NSDate *)prevDayDate {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate] - 24 * 3600];
}

- (NSDate *)nextDayDate {
    return [NSDate dateWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate] + 24 * 3600];
}

- (NSDate *)prevMonthDate {
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    if (components.month > 1) {
        [components setYear:0];
    } else {
        [components setYear:-1];
    }
    [components setMonth:-1];
    [components setDay:0];
    return [[NSDate currentCalendar] dateByAddingComponents:components
                                                         toDate:self
                                                        options:NSCalendarWrapComponents];
}

- (NSDate *)nextMonthDate {
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    if (components.month < 12) {
        [components setYear:0];
    } else {
        [components setYear:1];
    }
    [components setMonth:1];
    [components setDay:0];
    return [[NSDate currentCalendar] dateByAddingComponents:components
                                                         toDate:self
                                                        options:NSCalendarWrapComponents];
}

- (BOOL)isToday {
    NSString *date = [[NSDate date] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isTomorrow {
    NSString *date = [[[NSDate date] nextDayDate] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isYesterday {
    NSString *date = [[[NSDate date] prevDayDate] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isDayAfterTomorrow {
    NSString *date = [[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceReferenceDate] + 48 * 3600] dateString];
    return [date isEqualToString:[self dateString]];
}

- (BOOL)isDayBeforeYesterday {
    NSString *date = [[NSDate dateWithTimeIntervalSinceReferenceDate:[[NSDate date] timeIntervalSinceReferenceDate] - 48 * 3600] dateString];
    return [date isEqualToString:[self dateString]];
}

- (NSDateComponents *)componets {
    NSCalendarUnit units = (NSCalendarUnitEra |
                            NSCalendarUnitYear |
                            NSCalendarUnitMonth |
                            NSCalendarUnitDay |
                            NSCalendarUnitHour |
                            NSCalendarUnitMinute |
                            NSCalendarUnitSecond |
                            NSCalendarUnitWeekday |
                            NSCalendarUnitWeekdayOrdinal |
                            NSCalendarUnitQuarter |
                            NSCalendarUnitWeekOfMonth |
                            NSCalendarUnitWeekOfYear |
                            NSCalendarUnitYearForWeekOfYear |
                            NSCalendarUnitNanosecond |
                            NSCalendarUnitCalendar |
                            NSCalendarUnitTimeZone);
    return [[NSDate currentCalendar] components:units fromDate:self];
}

- (NSDate *)firstDayOfMonthDate {
    NSDateComponents *components = [[NSDate currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    components.day = 1;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSInteger)numberOfDaysInMonth {
    return [[NSDate currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

@end
