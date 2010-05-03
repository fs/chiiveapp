//
//  CHTableGroupItem.h
//  chiive
//
//  Created by 17FEET on 2/22/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableItem.h"

@class Group;


///////////////////////////////////////////////////////////////////////////////////////////////////


@interface CHTableGroupItem : TTTableSubtitleItem
{
	NSInteger	_numberOfFriends;
	NSInteger	_numberOfPeople;
	NSInteger	_numberOfPhotos;
	NSString	*_happenedAt;
}
@property (nonatomic, assign)	NSInteger	numberOfFriends;
@property (nonatomic, assign)	NSInteger	numberOfPeople;
@property (nonatomic, assign)	NSInteger	numberOfPhotos;
@property (nonatomic, retain)	NSString	*happenedAt;

+ (id)itemWithGroup:(Group *)group;
+ (id)itemWithGroup:(Group *)group URL:(NSString*)URL;
+ (id)itemWithGroup:(Group *)group URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL;
@end


///////////////////////////////////////////////////////////////////////////////////////////////////


@interface CHTableGroupItemCell : TTTableSubtitleItemCell
{
	UIImageView				*_photoPlaceholder;
	TTStyledTextLabel		*_infoLabel;
	UILabel					*_timeLabel;
	TTButton				*_joinButton;
}
@property (nonatomic, readonly) TTStyledTextLabel		*infoLabel;
@property (nonatomic, readonly) TTButton				*joinButton;
@property (nonatomic, readonly) UIImageView				*photoPlaceholder;
@end

