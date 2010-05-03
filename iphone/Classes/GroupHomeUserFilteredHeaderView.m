//
//  GroupHomeUserFilteredHeaderView.m
//  chiive
//
//  Created by Arrel Gray on 3/20/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupHomeUserFilteredHeaderView.h"
#import "Group.h"
#import "PostModel.h"
#import "User.h"
#import "CHAvatarView.h"


@implementation GroupHomeUserFilteredHeaderView
@synthesize group = _group;

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)updateGroupData
{
	_avatarView.urlPath = [self.group.postModel.filterByUser URLForAvatar];
	_userPhotosLabel.text = [NSString stringWithFormat:@"%d Photos by %@", 
							 self.group.postModel.numberOfPhotos,
							 self.group.postModel.filterByUser.displayName];
	[self setNeedsLayout];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setGroup:(Group *)group
{
	if (group != _group)
	{
		[[_group delegates] removeObject:self];
		[group retain];
		[_group release];
		
		_group = group;
		[[_group delegates] addObject:self];
		
		[self updateGroupData];
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor whiteColor];
		
		_backgroundView = [[TTView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 12)];
		_backgroundView.style = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithWhite:0.9 alpha:1] 
																	color2:[UIColor whiteColor]
																	  next:nil];
		[self addSubview:_backgroundView];
		
		_avatarView = [[CHAvatarView alloc] initWithFrame:CGRectZero];
		[self addSubview:_avatarView];
		
		_userPhotosLabel = [[UILabel alloc] init];
		_userPhotosLabel.font = [UIFont systemFontOfSize:15];
		_userPhotosLabel.textColor = [UIColor darkGrayColor];
		_userPhotosLabel.backgroundColor = [UIColor clearColor];
		_userPhotosLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:_userPhotosLabel];
	}
	return self;
}

- (void)layoutSubviews
{
	NSInteger padding = 3;
	NSInteger avatarSize = self.height - padding * 2;
	
	_avatarView.frame = CGRectMake(padding + 2, padding, avatarSize, avatarSize);
	_userPhotosLabel.frame = CGRectMake(_avatarView.right + padding, 
										0, 
										self.width - _avatarView.right - padding * 5, 
										self.height);
	
	[super layoutSubviews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (void)modelDidFinishLoad:(id<TTModel>)model {
	[self updateGroupData];
}

- (void)model:(id<TTModel>)model didInsertObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self updateGroupData];
}

- (void)model:(id<TTModel>)model didDeleteObject:(id)object atIndexPath:(NSIndexPath*)indexPath {
	[self updateGroupData];
}

- (void)modelDidChange:(id<TTModel>)model {
	[self updateGroupData];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	[[_group delegates] removeObject:self];
	TT_RELEASE_SAFELY(_group);
	TT_RELEASE_SAFELY(_backgroundView);
	TT_RELEASE_SAFELY(_avatarView);
	TT_RELEASE_SAFELY(_userPhotosLabel);
	
	[super dealloc];
}

@end
