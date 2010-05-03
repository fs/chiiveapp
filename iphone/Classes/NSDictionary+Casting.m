//
//  NSDictionary+Casting.m
//  spyglass
//
//  Created by 17FEET on 3/24/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "NSDictionary+Casting.h"

@implementation NSDictionary (Casting)

- (NSInteger)intForKey:(id)key
{
	id value = [self objectForKey:key];
	return nil == value ? 0 : [value intValue];
}

- (NSString *)stringForKey:(id)key
{
	NSString *value = [self objectForKey:key];
	return nil == value || [value isKindOfClass:[NSNull class]] ? nil : value;
}

- (NSNumber *)numberForKey:(id)key
{
	NSNumber *value = [self objectForKey:key];
	return nil == value || [value isKindOfClass:[NSNull class]] ? nil : value;
}


@end
