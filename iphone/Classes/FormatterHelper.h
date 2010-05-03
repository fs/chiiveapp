//
//  FormatterHelper.h
//  chiive
//
//  Created by Arrel Gray on 9/6/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FormatterHelper : NSObject {
}

/**
 * Convert NSDate to a string to send to the server.
 */
+ (NSString *)stringFromDateTime:(NSDate *)date;
+ (NSString *)utcStringFromDateTime:(NSDate *)date;

/**
 * Parse a string-based date from the server into NSDate.
 */
+ (NSDate *)dateTimeFromString:(NSString *)date;

@end
