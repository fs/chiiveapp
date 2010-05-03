//
//  NSDictionary+Casting.h
//  spyglass
//
//  Created by 17FEET on 3/24/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@interface NSDictionary (Casting)

- (NSInteger)intForKey:(id)key;

- (NSString *)stringForKey:(id)key;

- (NSNumber *)numberForKey:(id)key;

@end
