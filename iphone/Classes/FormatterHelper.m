//
//  FormatterHelper.m
//  chiive
//
//  Created by Arrel Gray on 9/6/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "FormatterHelper.h"


@implementation FormatterHelper


static NSString *dateTimeFormatString = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
//static NSString *dateTimeFormatStringShort = @"HH:mm:ss a";
static NSString *dateTimeZoneFormatString = @"yyyy-MM-dd'T'HH:mm:ssz";

+ (NSString *)stringFromDateTime:(NSDate *)dateTime
{
	if (nil == dateTime)
		return nil;
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:dateTimeFormatString];		
	return [formatter stringFromDate:dateTime];
}

+ (NSString *)utcStringFromDateTime:(NSDate *)dateTime
{
	if (nil == dateTime)
		return nil;
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:dateTimeFormatString];		
	[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	return [formatter stringFromDate:dateTime];
}

+ (NSDate *)dateTimeFromString:(NSString *)dateTimeString
{
	if (nil == dateTimeString)
		return nil;
	
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	
	if ([dateTimeString hasSuffix:@"Z"])
	{
		[formatter setDateFormat:dateTimeFormatString];
		[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	}
	else
	{
		[formatter setDateFormat:dateTimeZoneFormatString];
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
	}
	return [formatter dateFromString:dateTimeString];
}

@end
