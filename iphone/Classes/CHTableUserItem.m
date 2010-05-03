//
//  CHTableUserItem.m
//  chiive
//
//  Created by 17FEET on 2/26/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableUserItem.h"
#import "CHTableItem.h"
#import "Friendship.h"
#import "Global.h"
#import "User.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableUserItem : TTTableSubtitleItem
@synthesize accessoryText = _accessoryText, numberOfPhotos = _numberOfPhotos, padding = _padding;
+ (id)itemWithUser:(User *)user {
	return [[self class] itemWithUser:user URL:nil accessoryURL:nil];
}
+ (id)itemWithUser:(User *)user URL:(NSString*)URL {
	return [[self class] itemWithUser:user URL:URL accessoryURL:nil];
}
+ (id)itemWithUser:(User *)user URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
	CHTableUserItem* item = [[[self alloc] init] autorelease];
	item.userInfo = user;
	item.text = user.displayName;
	item.subtitle = [NSString stringWithFormat:@"%d Events", user.numGroups];
	item.defaultImage = [UIImage imageNamed:@"icon_person.png"];
	item.URL = user.isMutualFriend ? URL : nil;
	item.imageURL = user.URLForAvatar;
	item.accessoryURL = accessoryURL;
	item.padding = 0;
	
	if (user.isFriend && !user.isFan)
	{
		item.accessoryText = @"Invite Sent!";
	}
	else if (user.isFan && !user.isFriend)
	{
		item.accessoryText = @"Accept";
		item.accessoryURL = @"accept";
	} 
	else if (!user.isMutualFriend && user != [Global getInstance].currentUser) 
	{
		item.accessoryText = @"Add";
		item.accessoryURL = @"add";
	}
	
	return item;
}
- (void)setNumberOfPhotos:(NSInteger)numberOfPhotos
{
	_numberOfPhotos = numberOfPhotos;
	if (_numberOfPhotos)
		self.subtitle = [NSString stringWithFormat:@"%d Photos", numberOfPhotos];
	else
		self.subtitle = @"No Photos";
}
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableUserItemCell : TTTableSubtitleItemCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier]) {
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
		self.textLabel.minimumFontSize = self.textLabel.font.pointSize;
		self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
	}
	return self;
}
- (void)updateAccessoryType
{
	CHTableUserItem *item = self.object;
	
	// Create the "Add as Friend" or "Pending..." accessory control
	if (!!item.accessoryText) 
	{
		// if the accessory does not click through, just show text
		if (!item.accessoryURL)
		{
			UILabel *accessoryLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			accessoryLabel.font = [UIFont boldSystemFontOfSize:14];
			
			accessoryLabel.text = item.accessoryText;
			CGSize accessoryLabelSize = [accessoryLabel.text sizeWithFont:accessoryLabel.font];
			accessoryLabel.frame = CGRectMake(0, 0, accessoryLabelSize.width, accessoryLabelSize.height);
			accessoryLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
			self.accessoryView = accessoryLabel;
		}
		
		// if there is a clickthrough for the accessory, show a button
		else
		{
			TTButton *accessoryButton = [TTButton buttonWithStyle:@"smallRoundButton:" title:item.accessoryText];
			[accessoryButton sizeToFit];
			[accessoryButton addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
			self.accessoryView = accessoryButton;
		}
	}
	else
	{
		self.accessoryView = nil;
		[super updateAccessoryType];
	}
}

- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
//		CHTableUserItem *item = object;
		[self updateAccessoryType];
	}
}
- (void)checkButtonTapped:(id)sender event:(id)event
{
	UITableView *parentTable = (UITableView *)self.superview;
	NSIndexPath *indexPath = [parentTable indexPathForCell:self];
	TTTableViewDelegate *tableViewDelegate = (TTTableViewDelegate *)parentTable.delegate;
	[tableViewDelegate tableView:parentTable accessoryButtonTappedForRowWithIndexPath:indexPath];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableUserRequestItem : TTTableSubtitleItem
@synthesize accessoryText = _accessoryText;
+ (id)itemWithUser:(User *)user {
	return [[self class] itemWithUser:user URL:nil accessoryURL:nil];
}
+ (id)itemWithUser:(User *)user URL:(NSString*)URL {
	return [[self class] itemWithUser:user URL:URL accessoryURL:nil];
}
+ (id)itemWithUser:(User *)user URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL {
	CHTableUserRequestItem* item = [[[self alloc] init] autorelease];
	item.userInfo = user;
	item.text = user.displayName;
	
	// default message it "Accepted", which is covered up by buttons if not accepted
	item.subtitle = @"Accepted";
	item.defaultImage = [UIImage imageNamed:@"icon_person.png"];
	item.imageURL = user.URLForAvatar;
	item.accessoryURL = accessoryURL;
	return item;
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation CHTableUserRequestItemCell : TTTableSubtitleItemCell
@synthesize leftButton = _leftButton, rightButton = _rightButton,
			leftUrlPath = _leftUrlPath, rightUrlPath = _rightUrlPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier]) {
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
	}
	return self;
}
- (TTButton *)leftButton
{
	if (!_leftButton)
	{
		_leftButton = [[TTButton buttonWithStyle:@"discreteRoundButton:"] retain];
		[_leftButton addTarget:self action:@selector(buttonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_leftButton];
	}
	return _leftButton;
}
- (TTButton *)rightButton
{
	if (!_rightButton)
	{
		_rightButton = [[TTButton buttonWithStyle:@"discreteRoundButton:"] retain];
		[_rightButton addTarget:self action:@selector(buttonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_rightButton];
	}
	return _rightButton;
}
- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		CHTableUserRequestItem *item = object;
		User *user = item.userInfo;
		
		// if this is a pending friend
		if (user.isFan && !user.isFriend)
		{
			self.leftUrlPath = FRIEND_REQUEST_ACCEPT;
			[self.leftButton setTitle:@"Accept" forState:UIControlStateNormal];
			self.leftButton.enabled = YES;
			self.leftButton.hidden = NO;
			
			self.rightUrlPath = FRIEND_REQUEST_IGNORE;
			[self.rightButton setTitle:@"Ignore" forState:UIControlStateNormal];
			self.rightButton.enabled = YES;
			self.rightButton.hidden = NO;
		}
		else if (!user.isFan && user.isFriend)
		{
			self.leftUrlPath = nil;
			[self.leftButton setTitle:@"Pending..." forState:UIControlStateNormal];
			self.leftButton.enabled = NO;
			self.leftButton.hidden = NO;
			
			self.rightUrlPath = FRIEND_REQUEST_REMOVE;
			[self.rightButton setTitle:@"Remove" forState:UIControlStateNormal];
			self.rightButton.enabled = YES;
			self.rightButton.hidden = NO;
		}
		else if (!user.isMutualFriend)
		{
			self.leftUrlPath = FRIEND_REQUEST_ADD;
			[self.leftButton setTitle:@"Add as Friend" forState:UIControlStateNormal];
			self.leftButton.enabled = YES;
			self.leftButton.hidden = NO;
			
			self.rightUrlPath = nil;
			self.rightButton.hidden = YES;
		}
		else
		{
			self.leftUrlPath = nil;
			self.leftButton.hidden = YES;
			
			self.rightUrlPath = nil;
			self.rightButton.hidden = YES;
		}
		[self updateAccessoryType];
	}
}
- (void)buttonTapped:(id)sender event:(id)event
{
	// assign the corresponding url path
	CHTableUserRequestItem *item = self.object;
	item.accessoryURL = (sender == self.leftButton) ? self.leftUrlPath : self.rightUrlPath;
	
	// register the accessory click in the table view delegate
	UITableView *parentTable = (UITableView *)self.superview;
	NSIndexPath *indexPath = [parentTable indexPathForCell:self];
	TTTableViewDelegate *tableViewDelegate = (TTTableViewDelegate *)parentTable.delegate;
	[tableViewDelegate tableView:parentTable accessoryButtonTappedForRowWithIndexPath:indexPath];
	
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	
	if (self.leftButton.hidden && self.rightButton.hidden)
	{
		self.subtitleLabel.hidden = NO;
	}
	else
	{
		self.subtitleLabel.hidden = YES;
		self.textLabel.frame = CGRectOffset(self.textLabel.frame, 0, -10);
		
		NSInteger left = self.textLabel.left;
		NSInteger top = self.textLabel.bottom;
		
		if (!self.leftButton.hidden)
		{
			[self.leftButton sizeToFit];
			self.leftButton.frame = CGRectMake(left, top, self.leftButton.frame.size.width, self.leftButton.frame.size.height);
			left += self.leftButton.frame.size.width + 5;
		}
		
		if (!self.rightButton.hidden)
		{
			[self.rightButton sizeToFit];
			self.rightButton.frame = CGRectMake(left, top, self.rightButton.frame.size.width, self.rightButton.frame.size.height);
			left += self.rightButton.frame.size.width + 5;
		}
	}
	
	
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation CHTableUserInviteItem
@synthesize checked = _checked;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation CHTableUserInviteItemCell 
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier]) {
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	CHTableUserInviteItem *item = (CHTableUserInviteItem *)self.object;
	if (item.checked)
		self.backgroundColor = RGBCOLOR(226, 234, 237);
	else
		self.backgroundColor = [UIColor whiteColor];
}
- (void)setObject:(id)object {
	if (_item != object) {
		[super setObject:object];
		
		CHTableUserInviteItem *item = (CHTableUserInviteItem *)object;
		if (item.checked)
			self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_view_checked.png"]] autorelease];
		else
			self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_view_unchecked.png"]] autorelease];
	}
}
@end
