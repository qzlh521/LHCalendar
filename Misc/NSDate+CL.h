//
//  NSDate+CL.h
//  CLWeeklyCalendarView
//
//  Created by Caesar on 10/12/2014.
//  Copyright (c) 2014 Caesar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CL)
-(NSDate *)addDays:(NSInteger)day;
-(NSDate *)getWeekStartDate: (NSInteger)weekStartIndex;
-(NSDate *)getMonthStartDate: (NSInteger)weekStartIndex;
-(NSString *)getDayOfWeekShortString;
-(NSString *)getDateOfMonth;
-(BOOL) isSameDateWith: (NSDate *)dt;
- (BOOL)isDateToday;
- (BOOL)isWithinDate: (NSDate *)earlierDate toDate:(NSDate *)laterDate;
- (NSNumber *)getMonthDay;
- (NSNumber *)getYearDay;

- (BOOL)isPastDate;
- (NSDate*)midnightDate;

- (NSDate *)chineseCalendarDate;
@end

