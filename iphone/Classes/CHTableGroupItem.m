//
//  CHTableGroupItem.m
//  chiive
//
//  Created by 17FEET on 2/22/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableGroupItem.h"
#import "Group.h"
#import "Global.h"
#import "PostModel.h"
#import "UserModel.h"
#import "User.h"
#import "CHDefaultStyleSheet.h"
#import "TTTableViewControllerAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat	kPadding = 10;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableGroupItem
@synthesize numberOfPeople = _numberOfPeople, numberOfFriends = _numberOfFriends, 
			numberOfPhotos = _numberOfPhotos, happenedAt = _happenedAt;

+ (id)itemWithGroup:(Group *)group {
	return [[self class] itemWithGroup:group URL:nil accessoryURL:nil];
}
+ (id)itemWithGroup:(Group *)group URL:(NSString*)URL {
	return [[self class] itemWithGroup:group URL:URL accessoryURL:nil];
}
+ (id)itemWithGroup:(Group *)group URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
	CHTableGroupItem* item = [[[self alloc] init] autorelease];
	item.userInfo = group;
	item.defaultImage = [UIImage imageNamed:@"icon_person.png"];
	item.URL = URL;
	item.accessoryURL = accessoryURL;
	
	// set the basic info
	item.text = group.prettyTitle;
	
	NSString *ownerString = group.owner.displayName;
	
	NSInteger numAttendees = group.numUsers;
	NSString *othersString;
	if (numAttendees > 2)
		othersString = [NSString stringWithFormat:@" and %d others", group.friendModel.numberOfChildren];
	else if (numAttendees > 1)
		othersString = @" and 1 other";
	else
		othersString = @"";
	
	item.subtitle = [NSString stringWithFormat:@"%@%@", ownerString, othersString];
	item.happenedAt = @""; //[group.happenedAt formatRelativeTime];
	item.numberOfPhotos = group.numPosts;
	
	// set the thumbnail url
	if (group.postModel.numberOfChildrenLoaded > 0)
		item.imageURL = [(Post *)[group.postModel.children objectAtIndex:group.postModel.numberOfChildrenLoaded - 1] URLForVersion:TTPhotoVersionThumbnail];
	else
		item.imageURL = nil;
	
	// set the number of friends and people
//	item.numberOfPeople = group.friendModel.numberOfChildren;
//	item.numberOfFriends = 0;
//	for (User *user in group.friendModel.children) {
//		if (user.isMutualFriend)
//			item.numberOfFriends ++;
//	}
	
	return item;
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableGroupItemCell
+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return 92.0;
}
- (void)joinButtonWasPressed
{
	UITableView *parentTable = (UITableView *)self.superview;
	NSIndexPath *indexPath = [parentTable indexPathForCell:self];
	TTTableViewDelegate *tableViewDelegate = (TTTableViewDelegate *)parentTable.delegate;
	[tableViewDelegate tableView:parentTable accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (UIImageView *)photoPlaceholder {
	if (!_photoPlaceholder)
	{
		_photoPlaceholder = [[UIImageView alloc] init];
		
		UIImage *placeholderImage = [UIImage imageNamed:@"table_cell_group_photo_background.png"];
		_photoPlaceholder.frame = CGRectMake(3, 6, placeholderImage.size.width, placeholderImage.size.height);
		_photoPlaceholder.image = placeholderImage;
		
		[self.contentView insertSubview:_photoPlaceholder atIndex:1];
	}
	return _photoPlaceholder;
}
- (TTStyledTextLabel *)infoLabel {
	if (!_infoLabel) {
		_infoLabel = [[TTStyledTextLabel alloc] init];
		_infoLabel.textColor = [UIColor grayColor];
		_infoLabel.font = [UIFont systemFontOfSize:16];
		[self.contentView addSubview:_infoLabel];
	}
	return _infoLabel;
}
- (UILabel *)timeLabel {
	if (!_timeLabel) {
		_timeLabel = [[UILabel alloc] init];
		_timeLabel.textColor = [UIColor grayColor];
		_timeLabel.font = [UIFont systemFontOfSize:13];
		_timeLabel.highlightedTextColor = [UIColor whiteColor];
		[self.contentView addSubview:_timeLabel];
	}
	return _timeLabel;
}
- (TTButton *)joinButton
{
	if (nil == _joinButton)
	{
		_joinButton = [[TTButton buttonWithStyle:@"smallRoundButton:" title:@"Join >"] retain];
		[_joinButton sizeToFit];
		[_joinButton addTarget:self action:@selector(joinButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
	}
	return _joinButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier
{
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier]) {
		self.photoPlaceholder;
	}
	return self;
}


- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat padding = 2;
	CGFloat imageSize = 50;
	CGFloat left = 88;
	CGFloat top = 12;
	CGFloat width = self.contentView.width - left;
	
	_imageView2.frame = CGRectMake(14, 19, imageSize, imageSize);
	top += padding * 2;
	
	[self.timeLabel sizeToFit];
	self.timeLabel.frame = CGRectMake(self.contentView.width - self.timeLabel.width, top, self.timeLabel.width, self.timeLabel.font.ttLineHeight);
	
	self.textLabel.frame = CGRectMake(left, top, self.timeLabel.left - left, self.textLabel.font.ttLineHeight);
	top += self.textLabel.height;
	
	self.subtitleLabel.frame = CGRectMake(left, top, width, self.subtitleLabel.font.ttLineHeight);
	top += self.subtitleLabel.height;
	
	[self.infoLabel sizeToFit];
	self.infoLabel.frame = CGRectMake(left, top, self.subtitleLabel.width, self.infoLabel.font.ttLineHeight);
	left += self.infoLabel.width + padding;
}

- (void)setObject:(id)object 
{
	if (_item != object) 
	{
		[super setObject:object];
		
		self.textLabel.font = [UIFont boldSystemFontOfSize:18];
		self.textLabel.minimumFontSize = 18;
		self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
		
		self.subtitleLabel.font = [UIFont systemFontOfSize:16];
		self.subtitleLabel.minimumFontSize = 18;
		self.subtitleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.subtitleLabel.textColor = [UIColor grayColor];
		
		CHTableGroupItem *item = (CHTableGroupItem *)object;
		
		self.imageView2.hidden = !item.imageURL;

//		NSString *peopleString;
		
//		if (1 == item.numberOfPeople)
//			peopleString = [NSString stringWithFormat:@"<b>%d</b> %@", item.numberOfPeople, @"Person"];
//		else
//			peopleString = [NSString stringWithFormat:@"<b>%d</b> %@", item.numberOfPeople, @"People"];
		
		NSString *photosString;
		if (1 == item.numberOfPhotos)
			photosString = [NSString stringWithFormat:@"<b><span class=\"statsText\">%d</span></b> Photo", item.numberOfPhotos];
		else
			photosString = [NSString stringWithFormat:@"<b><span class=\"statsText\">%d</span></b> Photos", item.numberOfPhotos];
		
//		NSString *dataString = [NSString stringWithFormat:@"%@  |  %@", peopleString, photosString];
		self.infoLabel.text = [TTStyledText textFromXHTML:photosString]; //dataString];
		
		self.timeLabel.text = item.happenedAt;
		
		if (!item.URL) 
		{
			self.accessoryView = self.joinButton;
		}
		else
		{
			self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			self.accessoryView = nil;
		}
	}
}
- (void)dealloc
{
	TT_RELEASE_SAFELY(_photoPlaceholder);
	TT_RELEASE_SAFELY(_infoLabel);
	TT_RELEASE_SAFELY(_timeLabel);
	TT_RELEASE_SAFELY(_joinButton);
	[super dealloc];
}
@end
