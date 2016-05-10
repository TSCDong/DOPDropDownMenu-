//
//  PublicMethods.h
//  Wildto
//
//  Created by 詹可钟 on 14-4-29.
//  Copyright (c) 2014年 Wildto. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GlobalPublicMethods [PublicMethods sharePublicMethods]

@class MLExpression;

@interface PublicMethods : NSObject

+ (PublicMethods *)sharePublicMethods;

/**
 *  获取当前系统时间
 *  @return 返回字符串
 */
-(NSString *)getSystemTime;

/**
 *  获取当前系统时间戳
 *  @return 返回时间戳
 */
-(NSString *)getSystemTimestamp;

/**
 *  标准时间转化为时间戳
 *  @param str 标准时间
 *  @return 返回字符串时间戳
 */
-(NSString*)timeStamp:(NSString*)str;

/**
 *  时间戳转换成标准时间（带时间格式）
 *  @param str    标准时间
 *  @param format 时间格式
 *  @return 返回标准时间
 */
- (NSString*)formatTime:(NSString*)timeStamp format:(NSString *)format;

/**
 *  date时间换成标准时间
 *  @param date NSDate时间
 *  @return 标准时间字符串
 */
- (NSString *)formatTheTime:(NSDate *)date;






@end
