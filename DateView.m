//
//  CLWeeklyCalendarView.m
//  Deputy
//
//  Created by Caesar on 30/10/2014.
//  Copyright (c) 2014 Caesar Li. All rights reserved.
//

#import "DateView.h"
#import "DailyCalendarView.h"
#import "DayTitleLabel.h"

#import "NSDate+CL.h"
#import "UIColor+CL.h"
#import "NSDictionary+CL.h"
#import "UIImage+CL.h"
//#import "NTMonthCalendar.h"

#define WEEKLY_VIEW_COUNT 7
#define MONTH_VIEW_COUNT 42

#define DAY_TITLE_VIEW_HEIGHT 8.f
#define DAY_TITLE_FONT_SIZE 14.f
#define DATE_TITLE_MARGIN_TOP 5.f

#define DATE_VIEW_MARGIN 3.f
//#define DATE_VIEW_HEIGHT 28.f

#define DATE_VIEW_HEIGHT 55.f
#define MONTH_VIEW_HEIGHT /*500.f*/ self.bounds.size.height

#define DATE_LABEL_MARGIN_LEFT 9.f
#define DATE_LABEL_INFO_WIDTH 160.f
#define DATE_LABEL_INFO_HEIGHT 40.f

#define WEATHER_ICON_WIDTH 20
#define WEATHER_ICON_HEIGHT 20
#define WEATHER_ICON_LEFT 90
#define WEATHER_ICON_MARGIN_TOP 9


//Attribute Keys
NSString *const CLCalendarWeekStartDay = @"CLCalendarWeekStartDay";
NSString *const CLCalendarDayTitleTextColor = @"CLCalendarDayTitleTextColor";
NSString *const CLCalendarSelectedDatePrintFormat = @"CLCalendarSelectedDatePrintFormat";
NSString *const CLCalendarSelectedDatePrintColor = @"CLCalendarSelectedDatePrintColor";
NSString *const CLCalendarSelectedDatePrintFontSize = @"CLCalendarSelectedDatePrintFontSize";
NSString *const CLCalendarBackgroundImageColor = @"CLCalendarBackgroundImageColor";

//Default Values
static NSInteger const CLCalendarWeekStartDayDefault = 1;
static NSInteger const CLCalendarDayTitleTextColorDefault = 0xC2E8FF;
static NSString* const CLCalendarSelectedDatePrintFormatDefault = @"EEE, d MMM yyyy";
static float const CLCalendarSelectedDatePrintFontSizeDefault = 13.f;




@interface DateView()<DailyCalendarViewDelegate, UIGestureRecognizerDelegate>
{
    /**
     *  滑动结束后的date 用于记录最后的值
     */
    NSDate * _swipeResultDate;
}
/**
 *  设置显示阳历日期的view
 */
@property (nonatomic, strong) UIView *dailySubViewContainer;
/**
 *  设置显示星期几的view
 */
@property (nonatomic, strong) UIView *dayTitleSubViewContainer;
/**
 *  整体的背景 上面添加了相应的手势 包括左滑和右滑
 */
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIView *dailyInfoSubViewContainer;
@property (nonatomic, strong) UIImageView *weatherIcon;
@property (nonatomic, strong) UILabel *dateInfoLabel;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDictionary *arrDailyWeather;



@property (nonatomic, strong) NSNumber *weekStartConfig;
@property (nonatomic, strong) UIColor *dayTitleTextColor;
@property (nonatomic, strong) NSString *selectedDatePrintFormat;
@property (nonatomic, strong) UIColor *selectedDatePrintColor;
@property (nonatomic) float selectedDatePrintFontSize;
@property (nonatomic, strong) UIColor *backgroundImageColor;
@property (nonatomic) BOOL layoutWeekOrMonth;
@property (nonatomic,strong)NSDate * sourceDate;


@end

@implementation DateView

- (id)initWithFrame:(CGRect)frame andWithLayout:(BOOL)weekOrMonth andWithSourceDate:(NSDate *)sourceDate{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.arrDailyWeather = @{};
        self.layoutWeekOrMonth = weekOrMonth;
        self.selectedDate = sourceDate;
        self.sourceDate = sourceDate;
        self.userInteractionEnabled = YES;
        [self addSubview:self.backgroundImageView];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.backgroundImageView];
        self.arrDailyWeather = @{};
       
    }
    return self;
}


-(void)setDelegate:(id<CLWeeklyCalendarViewDelegate>)delegate
{
    _delegate = delegate;
    [self applyCustomDefaults];
}

-(void)applyCustomDefaults
{
    NSDictionary *attributes;
    
    if ([self.delegate respondsToSelector:@selector(CLCalendarBehaviorAttributes)]) {
        attributes = [self.delegate CLCalendarBehaviorAttributes];
    }
    
    self.weekStartConfig = attributes[CLCalendarWeekStartDay] ? attributes[CLCalendarWeekStartDay] : [NSNumber numberWithInt:CLCalendarWeekStartDayDefault];
    
    self.dayTitleTextColor = attributes[CLCalendarDayTitleTextColor]? attributes[CLCalendarDayTitleTextColor]:[UIColor colorWithHex:CLCalendarDayTitleTextColorDefault];
//    self.dayTitleTextColor = attributes[CLCalendarDayTitleTextColor]? attributes[CLCalendarDayTitleTextColor]:[UIColor blackColor];
    
    self.selectedDatePrintFormat = attributes[CLCalendarSelectedDatePrintFormat]? attributes[CLCalendarSelectedDatePrintFormat] : CLCalendarSelectedDatePrintFormatDefault;
    
    self.selectedDatePrintColor = attributes[CLCalendarSelectedDatePrintColor]? attributes[CLCalendarSelectedDatePrintColor] : [UIColor whiteColor];
//    self.selectedDatePrintColor = attributes[CLCalendarSelectedDatePrintColor]? attributes[CLCalendarSelectedDatePrintColor] : [UIColor redColor];
//    [UIColor colorWithRed:189/255.0 green:242/255.0 blue:248/255.0 alpha:1]
    
    self.selectedDatePrintFontSize = attributes[CLCalendarSelectedDatePrintFontSize]? [attributes[CLCalendarSelectedDatePrintFontSize] floatValue] : CLCalendarSelectedDatePrintFontSizeDefault;
    
//    NSLog(@"%@  %f", attributes[CLCalendarBackgroundImageColor],  self.selectedDatePrintFontSize);
    self.backgroundImageColor = attributes[CLCalendarBackgroundImageColor];
    
    [self setNeedsDisplay];
}

-(UIView *)dayTitleSubViewContainer
{
    if(!_dayTitleSubViewContainer){
        _dayTitleSubViewContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, DATE_TITLE_MARGIN_TOP, self.bounds.size.width, DAY_TITLE_VIEW_HEIGHT)];
        _dayTitleSubViewContainer.backgroundColor = [UIColor whiteColor];
        _dayTitleSubViewContainer.userInteractionEnabled = YES;
        
    }
    return _dayTitleSubViewContainer;
    
}
-(UIView *)dailySubViewContainer
{
    if(!_dailySubViewContainer){
        
        _dailySubViewContainer = [[UIImageView alloc] initWithFrame:CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT+DATE_VIEW_MARGIN, self.bounds.size.width, DATE_VIEW_HEIGHT)];
        if (_layoutWeekOrMonth) {
            _dailySubViewContainer.frame = CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT+DATE_VIEW_MARGIN, self.bounds.size.width, DATE_VIEW_HEIGHT);
        }else {
            _dailySubViewContainer.frame = CGRectMake(0, DATE_TITLE_MARGIN_TOP+DAY_TITLE_VIEW_HEIGHT+DATE_VIEW_MARGIN, self.bounds.size.width, MONTH_VIEW_HEIGHT);
        }
        _dailySubViewContainer.backgroundColor = [UIColor whiteColor];
        _dailySubViewContainer.userInteractionEnabled = YES;
        
    }
    return _dailySubViewContainer;
}
-(UIImageView *)backgroundImageView
{
    if(!_backgroundImageView){
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
//        _backgroundImageView.backgroundColor = [UIColor yellowColor];
        _backgroundImageView.userInteractionEnabled = YES;
        [_backgroundImageView addSubview:self.dayTitleSubViewContainer];
        [_backgroundImageView addSubview:self.dailySubViewContainer];
//        [_backgroundImageView addSubview:self.dailyInfoSubViewContainer];
        
        
        //Apply swipe gesture
        UISwipeGestureRecognizer *recognizerRight;
        recognizerRight.delegate=self;
        
        recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
        [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [_backgroundImageView addGestureRecognizer:recognizerRight];
        
        
        UISwipeGestureRecognizer *recognizerLeft;
        recognizerLeft.delegate=self;
        recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
        [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [_backgroundImageView addGestureRecognizer:recognizerLeft];
        _backgroundImageView.backgroundColor = [UIColor whiteColor];
    }
//    _backgroundImageView.backgroundColor = self.backgroundImageColor? self.backgroundImageColor : [UIColor colorWithPatternImage:[UIImage calendarBackgroundImage:self.bounds.size.height]];;
    return _backgroundImageView;
}
-(void)initDailyViews
{
    CGFloat dailyWidth = self.bounds.size.width/WEEKLY_VIEW_COUNT;
    
    for (UIView *v in [self.dailySubViewContainer subviews]){
        [v removeFromSuperview];
    }
    for (UIView *v in [self.dayTitleSubViewContainer subviews]){
        [v removeFromSuperview];
    }
//    NSDate *today = [NSDate new];
    NSDate *today = self.sourceDate;
    NSDate *dtWeekStart;
    int nums;
    if (self.layoutWeekOrMonth) {
        
       dtWeekStart  = [today getWeekStartDate:self.weekStartConfig.integerValue];
        self.startDate = dtWeekStart;
        
        nums = WEEKLY_VIEW_COUNT;
    }else {
        nums = MONTH_VIEW_COUNT;
        dtWeekStart =[today getMonthStartDate:self.weekStartConfig.integerValue];
        self.startDate = dtWeekStart;
    }
    for(int i = 0; i < nums; i++){
        NSDate *dt = [dtWeekStart addDays:i];
        if (i <= 6) {
            
            [self dayTitleViewForDate: dt inFrame: CGRectMake(dailyWidth*(i%WEEKLY_VIEW_COUNT), dailyWidth * (i/WEEKLY_VIEW_COUNT), dailyWidth, DAY_TITLE_VIEW_HEIGHT)];
        }
        
        [self dailyViewForDate:dt inFrame: CGRectMake((i%WEEKLY_VIEW_COUNT) * dailyWidth, dailyWidth * (i/WEEKLY_VIEW_COUNT), dailyWidth, DATE_VIEW_HEIGHT) ];
        
        self.endDate = dt;
    }
    if (self.layoutWeekOrMonth) {
    [self dailyCalendarViewDidSelect:self.sourceDate];    
    }
    
}

-(UILabel *)dayTitleViewForDate: (NSDate *)date inFrame: (CGRect)frame
{
    DayTitleLabel *dayTitleLabel = [[DayTitleLabel alloc] initWithFrame:frame];
    dayTitleLabel.backgroundColor = [UIColor clearColor];
//    dayTitleLabel.textColor = self.dayTitleTextColor;
    dayTitleLabel.textColor = [UIColor blackColor];
    dayTitleLabel.alpha = 0.5;
    dayTitleLabel.textAlignment = NSTextAlignmentCenter;
    dayTitleLabel.font = [UIFont systemFontOfSize:DAY_TITLE_FONT_SIZE];

    dayTitleLabel.text = [date getDayOfWeekShortString];
    dayTitleLabel.date = date;
    dayTitleLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dayTitleViewDidClick:)];
    [dayTitleLabel addGestureRecognizer:singleFingerTap];
    
    [self.dayTitleSubViewContainer addSubview:dayTitleLabel];
    return dayTitleLabel;
}

-(DailyCalendarView *)dailyViewForDate: (NSDate *)date inFrame: (CGRect)frame
{
    DailyCalendarView *view = [[DailyCalendarView alloc] initWithFrame:frame];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents * compontents = [[NSDateComponents alloc]init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit;
    compontents = [calendar components:unitFlags fromDate:date];
    
//   NTMonthCalendar *lunarCalendar = [[[NSCalendar currentCalendar] dateFromComponents:compontents] chineseCalendarDate];
//    NSLog(@"%@",lunarCalendar.DayLunar);
//    view.lunarDateString = lunarCalendar.DayLunar;
    view.date = date;
    
    if (!self.layoutWeekOrMonth) {
        //获取到月份
        int month = [[self.selectedDate getMonthDay] intValue];
        //获取到年份
        int year = [[self.selectedDate  getYearDay] intValue];
        
        NSString * MonthDt =[NSString stringWithFormat:@"%d-%d-01 16:00:00",year,month];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.selectedDate];
        NSUInteger numberOfDaysInMonth = range.length;
        NSString * MonthEnd = [NSString stringWithFormat:@"%d-%d-%d 16:00:00",year,month,(int)numberOfDaysInMonth];
        NSDateFormatter * formmart = [NSDateFormatter new];
        [formmart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate * dateMonthStart = [formmart dateFromString:MonthDt];
        NSDate * dateMonthEnd = [formmart dateFromString:MonthEnd];
        
        /*
         typedef NS_ENUM(NSInteger, NSComparisonResult) {NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending};
         
         */
        if ([dateMonthStart compare:date] == NSOrderedDescending || [dateMonthEnd compare:date] == NSOrderedAscending){
            view.date = nil;
            view.lunarDateString = @"";
            view.userInteractionEnabled = NO;
        }
        
    }
    
    
    
    
    [view markSelected:NO andWithWeekOrMonth:self.layoutWeekOrMonth andWithDate:date];
   
    
    view.backgroundColor = [UIColor clearColor];
    view.delegate = self;
    [self.dailySubViewContainer addSubview:view];
    return view;
}
/**
 *  获取一个月的第一天和最后一天
 *
 *  @return 返回一个数组 第一天firstObject 最后一天lastObject
 */
- (NSArray *)getTheMonthStartAndEndWithDate:(NSDate *)date{
    //获取到月份
    int month = [[date getMonthDay] intValue];
    //获取到年份
    int year = [[date  getYearDay] intValue];
    
    NSString * MonthDt =[NSString stringWithFormat:@"%d-%d-01 16:00:00",year,month];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSUInteger numberOfDaysInMonth = range.length;
    NSString * MonthEnd = [NSString stringWithFormat:@"%d-%d-%d 16:00:00",year,month,(int)numberOfDaysInMonth];
    NSDateFormatter * formmart = [NSDateFormatter new];
    [formmart setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * dateMonthStart = [formmart dateFromString:MonthDt];
    NSDate * dateMonthEnd = [formmart dateFromString:MonthEnd];
    return @[dateMonthStart,dateMonthEnd];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self initDailyViews];
    
}

-(void)markDateSelected:(NSDate *)date
{
    for (DailyCalendarView *v in [self.dailySubViewContainer subviews]){
        [v markSelected:([v.date isSameDateWith:date]) andWithWeekOrMonth:self.layoutWeekOrMonth andWithDate:date];
    }
    self.selectedDate = date;
}
-(void)dayTitleViewDidClick: (UIGestureRecognizer *)tap
{
    [self redrawToDate:((DayTitleLabel *)tap.view).date];
}
-(void)redrawToDate:(NSDate *)dt
{
//    if(![dt isWithinDate:self.startDate toDate:self.endDate]){
        BOOL swipeRight = ([dt compare:self.startDate] == NSOrderedAscending);
        [self delegateSwipeAnimation:swipeRight blnToday:[dt isDateToday] selectedDate:dt];
//    }
    
//    [self dailyCalendarViewDidSelect:dt];
    _swipeResultDate = dt;
    [self markDateSelected:dt];
}

#pragma swipe 
-(void)swipeLeft: (UISwipeGestureRecognizer *)swipe
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date;
    if (self.layoutWeekOrMonth) {
       date = [NSDate dateWithTimeInterval:WEEKLY_VIEW_COUNT*24*3600 sinceDate:self.selectedDate];
    }else {

        NSDateComponents * components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.selectedDate];

        NSDateComponents *componentsNext = [[NSDateComponents alloc] init];
        
        NSInteger month;
        NSInteger year;
        if (components.month == 12) {
            month = 1;
            year = components.year + 1;
        }else {
            month = components.month + 1;
            year = components.year;
        }
        [componentsNext setMonth:month];
        [componentsNext setYear:year];
        [componentsNext setDay:components.day];
        [componentsNext setHour:16];
        
 
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        date = [gregorian dateFromComponents:componentsNext];
//        date = [date mi];

    }
    [self redrawToDate:date];

}


-(void)swipeRight: (UISwipeGestureRecognizer *)swipe
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSDate * date;
    if (self.layoutWeekOrMonth) {
        date = [NSDate dateWithTimeInterval:-WEEKLY_VIEW_COUNT*24*3600 sinceDate:self.selectedDate];
    }else {
        
        NSDateComponents * components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.selectedDate];
        
        NSDateComponents *componentsNext = [[NSDateComponents alloc] init];
        
        NSInteger month;
        NSInteger year;
        if (components.month == 1) {
            month = 12;
            year = components.year - 1;
        }else {
            month = components.month - 1;
            year = components.year;
        }
        [componentsNext setMonth:month];
        [componentsNext setYear:year];
        [componentsNext setDay:components.day];
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        date = [gregorian dateFromComponents:componentsNext];
        date = [self getNowDateFromatAnDate:date];
    }

    [self redrawToDate:date];
//    [self delegateSwipeAnimation: YES blnToday:NO selectedDate:nil];
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    if ([self.delegate respondsToSelector:@selector(animationCalenderDidStop:finished: andWithDate:)]) {
        [self.delegate animationCalenderDidStop:anim finished:flag andWithDate:_swipeResultDate];
    }
}
-(void)delegateSwipeAnimation: (BOOL)blnSwipeRight blnToday: (BOOL)blnToday selectedDate:(NSDate *)selectedDate
{
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(blnSwipeRight)?kCATransitionFromLeft:kCATransitionFromRight];
    [animation setDuration:0.6];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.dailySubViewContainer.layer addAnimation:animation forKey:kCATransition];
    
    NSMutableDictionary *data = @{@"blnSwipeRight": [NSNumber numberWithBool:blnSwipeRight], @"blnToday":[NSNumber numberWithBool:blnToday]}.mutableCopy;
    
    if(selectedDate){
        [data setObject:selectedDate forKey:@"selectedDate"];
    }
    
    [self performSelector:@selector(renderSwipeDates:) withObject:data afterDelay:0.05f];
}


//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    return self;
//}
-(void)renderSwipeDates: (NSDictionary*)param
{
    int step = ([[param objectForKey:@"blnSwipeRight"] boolValue])? -1 : 1;
    BOOL blnToday = [[param objectForKey:@"blnToday"] boolValue];
    NSDate *selectedDate = [param objectForKeyWithNil:@"selectedDate"];
    CGFloat dailyWidth = self.bounds.size.width/WEEKLY_VIEW_COUNT;
    
    
    NSDate *dtStart;
    
    if (self.layoutWeekOrMonth) {
        //周
    
    if(blnToday){
        dtStart = [[NSDate new] getWeekStartDate:self.weekStartConfig.integerValue];
    }else{
        dtStart = (selectedDate)? [selectedDate getWeekStartDate:self.weekStartConfig.integerValue]:[self.startDate addDays:step*7];
    }
    }else {
        //月

        dtStart = [selectedDate getMonthStartDate:self.weekStartConfig.integerValue];;
    }
    
    


    self.startDate = dtStart;
    for (UIView *v in [self.dailySubViewContainer subviews]){
        [v removeFromSuperview];
    }
    
    int nums;
    if (self.layoutWeekOrMonth) {

        nums = WEEKLY_VIEW_COUNT;
    }else {
        nums = MONTH_VIEW_COUNT;
        
    }
    
    for(int i = 0; i < nums; i++){
        NSDate *dt = [dtStart addDays:i];

       DailyCalendarView* view = [self dailyViewForDate:dt inFrame: CGRectMake((i%WEEKLY_VIEW_COUNT) * dailyWidth, dailyWidth * (i/WEEKLY_VIEW_COUNT), dailyWidth, DATE_VIEW_HEIGHT) ];
        
        [view markSelected:([view.date isSameDateWith:self.selectedDate])];
        
        self.endDate = dt;
    }
    
}


#pragma DeputyDailyCalendarViewDelegate
-(void)dailyCalendarViewDidSelect:(NSDate *)date
{
    [self markDateSelected:date];
    
    [self.delegate dailyCalendarViewDidSelect:date];
}




@end
