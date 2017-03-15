//
//  DailyCalendarView.m
//  Deputy
//
//  Created by Caesar on 30/10/2014.
//  Copyright (c) 2014 Caesar Li
//
#import "DailyCalendarView.h"
#import "NSDate+CL.h"
#import "UIColor+CL.h"

@interface DailyCalendarView()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *dateLabelContainer;
@property (nonatomic,strong)UILabel * lunarDateLable;
@end


//#define DATE_LABEL_SIZE 28
#define DATE_LABEL_FONT_SIZE 16
#define LUNAR_LABLE_FONT_SIZE 12
#define DATE_LABEL_SIZE 42
#define DIS_DATE_LUNAR 3


@implementation DailyCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.dateLabelContainer];
        
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyViewDidClick:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}



-(UIView *)dateLabelContainer
{
    if(!_dateLabelContainer){
        float x = (self.bounds.size.width - DATE_LABEL_SIZE)/2;
        _dateLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(x, 0, DATE_LABEL_SIZE, DATE_LABEL_SIZE)];
        _dateLabelContainer.backgroundColor = [UIColor clearColor];
        _dateLabelContainer.layer.cornerRadius = DATE_LABEL_SIZE/2;
        _dateLabelContainer.clipsToBounds = YES;
        [_dateLabelContainer addSubview:self.dateLabel];
        [_dateLabelContainer addSubview:self.lunarDateLable];
    }
    return _dateLabelContainer;
}
- (UILabel *)lunarDateLable {
    if (!_lunarDateLable) {
        _lunarDateLable = [[UILabel alloc] initWithFrame:CGRectMake(0, DATE_LABEL_SIZE/2 + DIS_DATE_LUNAR, DATE_LABEL_SIZE, DATE_LABEL_SIZE/2)];
        _lunarDateLable.backgroundColor = [UIColor clearColor];
        _lunarDateLable.alpha = 0.6;
        _lunarDateLable.textColor = [UIColor whiteColor];
        _lunarDateLable.textAlignment = NSTextAlignmentCenter;
        _lunarDateLable.font = [UIFont systemFontOfSize:LUNAR_LABLE_FONT_SIZE];
    }
    return _lunarDateLable;
}
-(UILabel *)dateLabel
{
    if(!_dateLabel){
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, DATE_LABEL_SIZE, DATE_LABEL_SIZE/2)];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:DATE_LABEL_FONT_SIZE];
    }
    
    return _dateLabel;
}

-(void)setDate:(NSDate *)date
{
    _date = date;
    
    [self setNeedsDisplay];
}
-(void)setBlnSelected: (BOOL)blnSelected
{
    _blnSelected = blnSelected;
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    static NSDateFormatter *dateFormaater;
    if(!dateFormaater){
        dateFormaater = [[NSDateFormatter alloc] init];
        [dateFormaater setDateFormat:@"d"];
    }
    
    NSString * darelabText = [dateFormaater stringFromDate:self.date];
//self.dateLabel.text = [self.date getDateOfMonth];
    self.dateLabel.text = darelabText;
    self.lunarDateLable.text = self.lunarDateString;
}

- (void)markSelected:(BOOL)blnSelected andWithWeekOrMonth:(BOOL)weekOrMonth andWithDate:(NSDate *)date{
/*
 

 */
    
    if([self.date isDateToday]){
//        self.dateLabelContainer.backgroundColor = (blnSelected)?[UIColor redColor]: [UIColor colorWithHex:0x0081c1];
        self.dateLabelContainer.backgroundColor = (blnSelected)?[UIColor redColor]: [UIColor whiteColor];
//        self.dateLabel.textColor = (blnSelected)?[UIColor colorWithHex:0x0081c1]:[UIColor whiteColor];
        self.dateLabel.textColor = (blnSelected)?[UIColor whiteColor]:[UIColor redColor];
        self.lunarDateLable.textColor = (blnSelected)?[UIColor whiteColor]:[UIColor redColor];
    }else{

        self.dateLabelContainer.backgroundColor = (blnSelected)?[UIColor colorWithRed:189/255.0 green:242/255.0 blue:248/255.0 alpha:0.8]: [UIColor clearColor];
        
        self.dateLabel.textColor = (blnSelected)?[UIColor blackColor]:[self colorByDate];
        self.lunarDateLable.textColor = (blnSelected)?[UIColor blackColor]:[self colorByDate];
        
    }
    
    
}
-(void)markSelected:(BOOL)blnSelected
{
    //    DLog(@"mark date selected %@ -- %d",self.date, blnSelected);
    if([self.date isDateToday]){
        self.dateLabelContainer.backgroundColor = (blnSelected)?[UIColor redColor]: [UIColor whiteColor];
        self.dateLabel.textColor = (blnSelected)?[UIColor whiteColor]:[UIColor redColor];
        self.lunarDateLable.textColor = (blnSelected)?[UIColor whiteColor]:[UIColor redColor];
    }else{
        self.dateLabelContainer.backgroundColor = (blnSelected)?[UIColor colorWithRed:189/255.0 green:242/255.0 blue:248/255.0 alpha:0.8]: [UIColor clearColor];
        
        self.dateLabel.textColor = (blnSelected)?[UIColor blackColor]:[self colorByDate];
        self.lunarDateLable.textColor = (blnSelected)?[UIColor blackColor]:[self colorByDate];
    }
}
-(UIColor *)colorByDate
{
//    return [self.date isPastDate]?[UIColor colorWithHex:0x7BD1FF]:[UIColor whiteColor];
    return [self.date isPastDate]?[UIColor blackColor]:[UIColor blackColor];
}

-(void)dailyViewDidClick: (UIGestureRecognizer *)tap
{
    [self.delegate dailyCalendarViewDidSelect: self.date];
}
@end

