//
//  PublicMethods.m
//  Wildto
//
//  Created by 詹可钟 on 14-4-29.
//  Copyright (c) 2014年 Wildto. All rights reserved.
//

#import "PublicMethods.h"
#import "AppDelegate.h"

#import "NSDate+Extension.h"

#define EMOJIREGEX @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"

@implementation PublicMethods

+ (PublicMethods *)sharePublicMethods
{
    static PublicMethods *single;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        single = [[PublicMethods alloc] init];
    });
    return single;
}

//获取当前系统时间
-(NSString *)getSystemTime
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateTime= [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

//获取当前系统时间戳
-(NSString *)getSystemTimestamp
{
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowDate = [formater stringFromDate:[NSDate date]];
    NSDate *date = [formater dateFromString:nowDate];
    NSString *timeSp = [NSString stringWithFormat:@"%.f", [date timeIntervalSince1970]];
    return timeSp;
}

//标准时间转化为时间戳1111
-(NSString*)timeStamp:(NSString*)str
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formater dateFromString:str];
    NSString *timeSp = [NSString stringWithFormat:@"%.f", [date timeIntervalSince1970]];
    return timeSp;
}

//时间戳字符串转换成标准时间（自带格式）111111
- (NSString*)formatTime:(NSString*)timeStamp format:(NSString *)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStamp doubleValue]];
    NSString * dateTime = [formatter stringFromDate:date];
    return dateTime;
}

//date时间换成标准时间11111
- (NSString *)formatTheTime:(NSDate *)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateTime= [formatter stringFromDate:date];
    return dateTime;
}
@end
