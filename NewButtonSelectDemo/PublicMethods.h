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
 *  时间戳转换微博时间格式
 *  @param timestamp 时间戳
 *  @return 时间字符串
 */
- (NSString *)standardTimeStrWithTimestamp:(NSString *)timestamp;

/**
 *  时间戳转成星期几格式
 *  @param timestamp 时间戳
 *  @return 星期几
 */
- (NSString *)weekStrWithTimestamp:(NSString *)timestamp;

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
 *  时间戳转换成标准时间
 *  @param str 时间戳
 *  @return 返回标准时间
 */
- (NSString*)formatTime:(NSString*)timeStamp;

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

/**
 *  求两个时间的时差
 *  @param newTime 新的时间
 *  @param oldTime 旧的时间
 *  @return 返回时差
 */
- (NSString*)timeDifference:(NSString*)newTime ToOld:(NSString *)oldTime;

/**
 *  根据时间戳得到对应的时间字符串
 *  @param dateTimeValue 时间戳
 *  @return 返回时间字符串
 */
- (NSString *)timeStringByTimeValue:(double)dateTimeValue;

- (NSString *)speedToKMPerHourString:(double)speed;

- (NSInteger)intervalSinceNow: (NSString *) theDate;

- (NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;

- (NSString *)jsonStringWithArray:(NSArray *)array;

- (NSString *) jsonStringWithObject:(id) object;

- (NSString *) jsonStringWithString:(NSString *) string;

/**
 *  计算一段字符串的长度，两个英文字符占一个长度。
 *  @param str 传入要处理的字符串
 *  @return 返回字符串长度
 */
- (int)countTheStrLength:(NSString*)str;

/**
 *  获取Document目录路径
 *  @return 返回路劲Path
 */
-(NSString *)getDocumetPath;

/**
 *  判断NSString字符串是否包含emoji表情
 *  @param string 传入要处理的字符串
 *  @return 返回是否包含BOOL
 */
- (BOOL)stringContainsEmoji:(NSString *)string;



/**
 *  验证邮箱
 */
- (BOOL)isOKEmail:(NSString *)string;

/**
 *  验证身份证
 */
- (BOOL)isOKIdentityCard:(NSString *)string;

/**
 *  验证手机号码
 */
- (BOOL)isOKTelephone:(NSString *)string;

/**
 *  去除UITableView多余cell的分隔线
 *  @param tableView 传入tableView
 */
/**
 *  去掉字符串左右两端的空格
 */
- (NSString *)removeStringBothEndsSpace:(NSString *)string;

/**
 *  验证昵称
 *  @param text 昵称
 *  @return 验证结果
 */
- (BOOL)isUserName:(NSString *)text;

/*
 *  表情管理
 */
- (MLExpression *)expression;

/* 获取一个随机整数，范围在[from,to），包括from，不包括to  10000~100000 */
- (int)getRandomNumber:(int)from to:(int)to;

/** 身份证号码处理,前4后3中间以*拼接,返回处理好的字符串 */
- (NSString *)identityCardWithAsterisk:(NSString *)identityCard;

/** 护照处理,前3后2中间以*拼接,返回处理好的字符串 */
- (NSString *)passportWithAsterisk:(NSString *)passport;

/** 港澳通行证处理,前2后2中间以*拼接,返回处理好的字符串 */
- (NSString *)hongKongAndMacaoPassportWithAsterisk:(NSString *)passport;

/** 台湾通行证处理,前2后2中间以*拼接,返回处理好的字符串 */
- (NSString *)taiwanPassportWithAsterisk:(NSString *)passport;

/**
 *  设备分辨率
 *  @return 返回设备分辨率
 */
- (NSString *)deviceResolution;

/**
 *  数量格式计算
 *  @param count 数量
 *  @return 计算好的格式
 */
- (NSString *)countFormatWithCount:(NSInteger)count;


@end
