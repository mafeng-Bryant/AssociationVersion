//
//  Common.m
//  Profession
//
//  Created by MC374 on 12-8-7.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Common.h"
#import "Encry.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>  
#include <net/if.h>
#include <net/if_dl.h>
#import "SvUDIDTools.h"

@implementation Common

+(BOOL)connectedToNetwork{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
    return (isReachable && !needsConnection) ? YES : NO;
}

+(NSString*)TransformJson:(NSMutableDictionary*)sourceDic withLinkStr:(NSString*)strurl{
	SBJsonWriter *writer = [[SBJsonWriter alloc]init];
	NSString *jsonConvertedObj = [writer stringWithObject:sourceDic];
	//NSLog(@"jsonConvertedObj:%@",jsonConvertedObj);
    [writer release];
	NSString *b64 = [Common encodeBase64:(NSMutableData *)[jsonConvertedObj dataUsingEncoding: NSUTF8StringEncoding]];
	NSString *urlEncode = [Common URLEncodedString:b64];
	NSString *reqStr = [NSString stringWithFormat:strurl,urlEncode];
	//NSLog(@"req_string:%@",reqStr);
	return reqStr;
}

+(NSString*)encodeBase64:(NSMutableData*)data{
	size_t outputDataSize = EstimateBas64EncodedDataSize([data length]);
	Byte outputData[outputDataSize];
	Base64EncodeData([data bytes], [data length], outputData,&outputDataSize, YES);
	NSData *theData = [[NSData alloc]initWithBytes:outputData length:outputDataSize];//create a NSData object from the decoded data
	NSString *stringValue1 = [[NSString alloc]initWithData:theData encoding:NSUTF8StringEncoding];
	//NSLog(@"reqdata string base64 %@",stringValue1);
	[theData release];
	return [stringValue1 autorelease];
}
+ (NSString*)URLEncodedString:(NSString*)input  
{  
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,  
                                                                           (CFStringRef)input,  
                                                                           NULL,  
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),  
                                                                           kCFStringEncodingUTF8);  
    [result autorelease];  
    return result;  
}  
+ (NSString*)URLDecodedString:(NSString*)input  
{  
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,  
                                                                                           (CFStringRef)input,  
                                                                                           CFSTR(""),  
                                                                                           kCFStringEncodingUTF8);  
    [result autorelease];  
    return result;    
}  

+(NSNumber*)getVersion:(int)commandId{
	NSArray *ar_version = [DBOperate queryData:T_VERSION theColumn:@"command_id" 
								theColumnValue:[NSString stringWithFormat:@"%d",commandId] withAll:NO];
	
	if ([ar_version count]>0) {
		NSArray *arr_version = [ar_version objectAtIndex:0];
		return [arr_version objectAtIndex:version_ver];
	}
	else {
		return [NSNumber numberWithInt:0];
	}
}

+ (NSNumber*)getMemberVersion:(int)memberId commandID:(int)_commandId
{
	NSArray *ar_version = [DBOperate qureyWithTwoConditions:T_MEMBER_VERSION ColumnOne:@"commandId" valueOne:[NSString stringWithFormat:@"%d",_commandId] columnTwo:@"memberId" valueTwo:[NSString stringWithFormat:@"%d",memberId]];
	if ([ar_version count]>0) {
		NSArray *arr_version = [ar_version objectAtIndex:0];
		return [arr_version objectAtIndex:member_ver];
	}
	else {
		return [NSNumber numberWithInt:0];
	}
}

+ (NSNumber*)getCommentListVersion:(int)_typeId withInfoID:(int)_infoId
{
	NSArray *ar_version = [DBOperate qureyWithTwoConditions:T_COMMENTLIST_VERSION ColumnOne:@"typeId" valueOne:[NSString stringWithFormat:@"%d",_typeId] columnTwo:@"infoId" valueTwo:[NSString stringWithFormat:@"%d",_infoId]];
	if ([ar_version count]>0) {
		NSArray *arr_version = [ar_version objectAtIndex:0];
		return [arr_version objectAtIndex:version_list_ver];
	}
	else {
		return [NSNumber numberWithInt:0];
	}
}

+(NSString*)getSecureString{
	NSString *keystring = [NSString stringWithFormat:@"%d%@",SITE_ID,SignSecureKey];
	NSString *securekey = [Encry md5:keystring];
	return securekey;
}

#define	CTL_NET		4		/* network, see socket.h */
+ (NSString*)getMacAddress{
    return [SvUDIDTools UDID];
}


//判断是否为新会员 前7天到现在注册的会员
+(BOOL)isNewMember:(int)time
{
    long long int created = (long long int)time;
    NSDate* cDate = [NSDate date];   //当前日期
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    //[outputFormat setTimeZone:[NSTimeZone timeZoneWithName:@"H"]]; 
    [outputFormat setDateFormat:@"YYYY-MM-dd YYYY-MM-dd HH:mm:ss"];
    NSString *dateString = [outputFormat stringFromDate:cDate];
    NSDate *currentDate = [outputFormat dateFromString:dateString];     //当天凌晨 00:00:00 时间格式
    [outputFormat release];
    
    NSTimeInterval cTime = [currentDate timeIntervalSince1970];   //转化为时间戳
    long long int currentTime = (long long int)cTime;       //转成long long
    created = created + (7 * 24 * 60 * 60) - 1;
    
    if (currentTime > created)
    {
        return NO;
    }else
    {
        return YES;
    }
}

//转换友好的时间格式
+(NSString *)getFriendDate:(int)startTime eTime:(int)endTime
{
    //当前时间
    //NSTimeInterval cTime = [[NSDate date] timeIntervalSince1970];
    //long long int currentTime = (long long int)cTime;
    NSString *dateString =@"";
    NSDate* currentDate = [NSDate date];
    
    //开始时间
    NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDate* endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    
    //当前年
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
    [outputFormat setDateFormat:@"yyyy"];
    NSString *currentYear = [outputFormat stringFromDate:currentDate];
    NSString *startYear = [outputFormat stringFromDate:startDate];
    
    //判断开始时间是否与当前年同年
    if ([currentYear isEqualToString:startYear])
    {
        //判断开始年跟结束年是否同年
        NSString *endYear = [outputFormat stringFromDate:endDate];
        if (([startYear isEqualToString:endYear]))
        {
            //判断是否同一天
            [outputFormat setDateFormat:@"MM/dd"];
            NSString *startMonthAndDay = [outputFormat stringFromDate:startDate];
            NSString *endMonthAndDay = [outputFormat stringFromDate:endDate];
            if (([startMonthAndDay isEqualToString:endMonthAndDay]))
            {
                //eg: 04/28 18:00 至 18:30
                [outputFormat setDateFormat:@"MM/dd HH:mm"];
                NSString *startDateString = [outputFormat stringFromDate:startDate];
                [outputFormat setDateFormat:@"HH:mm"];
                NSString *endDateString = [outputFormat stringFromDate:endDate];
                dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
            }
            else
            {
                //eg: 04/28 18:00 至 04/29 12:30
                [outputFormat setDateFormat:@"MM/dd HH:mm"];
                NSString *startDateString = [outputFormat stringFromDate:startDate];
                NSString *endDateString = [outputFormat stringFromDate:endDate];
                dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
            }
        }
        else
        {
            //eg: 12/28 18:00 至 2014/01/03 18:30
            [outputFormat setDateFormat:@"MM/dd HH:mm"];
            NSString *startDateString = [outputFormat stringFromDate:startDate];
            [outputFormat setDateFormat:@"yyyy/MM/dd HH:mm"];
            NSString *endDateString = [outputFormat stringFromDate:endDate];
            dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
        }
    }
    else
    {
        //eg: 2012/01/01 18:00 至 2012/01/01 18:30
        [outputFormat setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *startDateString = [outputFormat stringFromDate:startDate];
        NSString *endDateString = [outputFormat stringFromDate:endDate];
        dateString = [NSString stringWithFormat:@"%@ 至 %@",startDateString,endDateString];
    }
    [outputFormat release];
    
    
    return dateString;
}

@end
