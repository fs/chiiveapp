//
//  GroupInfoViewController.m
//  chiive
//
//  Created by 17FEET on 2/23/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "Group.h"
#import "PostModel.h"
#import "Post.h"
#import "User.h"

@implementation GroupInfoViewController
@synthesize group = _group, thumbnailView = _thumbnailView, titleLabel = _titleLabel,
			ownerLabel = _ownerLabel, privacyHeaderLabel = _privacyHeaderLabel,
			privacyLabel = _privacyLabel, removeMeButton = _removeMeButton;


////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)updateGroupContent
{
	if (!!self.group && !!self.titleLabel)
	{
		self.titleLabel.text = self.group.prettyTitle;
		self.ownerLabel.text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<a href=\"owner\">%@</a> started this event", self.group.owner.displayName]];
		
		if (GroupPrivacyWhoCanJoinAll == self.group.privacyWhoCanJoin)
			self.privacyLabel.text = @"This event is open to the public.";
		else
			self.privacyLabel.text = @"This event is open to your extended network.";
		
		[self.privacyLabel sizeToFit];
		
		if (self.group.postModel.numberOfChildren > 0)
		{
			self.thumbnailView.hidden = NO;
			Post *post = (Post *)[self.group.postModel.children objectAtIndex:0];
			self.thumbnailView.urlPath = [post URLForVersion:TTPhotoVersionThumbnail];
		}
		else
		{
			self.thumbnailView.hidden = YES;
		}
		
		self.removeMeButton.hidden = !self.group.isCurrentUserGroup;
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setGroup:(Group *)group
{
	if (group != _group)
	{
		[group retain];
		[_group release];
		_group = group;
		[self updateGroupContent];
	}
}


////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	
	self.title = @"Event Info";
	
	NSInteger padding = 15;
	NSInteger left = padding;
	NSInteger top = padding;
	NSInteger width = self.view.frame.size.width;
	NSInteger thumbSize = 55;
	
	_thumbnailView = [[TTImageView alloc] initWithFrame:CGRectMake(left, top, thumbSize, thumbSize)];
	[self.view addSubview:_thumbnailView];
	left += thumbSize + padding;
	top += 5;
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width - left - padding, 30)];
	_titleLabel.font = [UIFont boldSystemFontOfSize:20];
	_titleLabel.textColor = [UIColor blackColor];
	_titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	_titleLabel.numberOfLines = 2;
//	_titleLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_titleLabel];
	top += _titleLabel.frame.size.height;
	
	_ownerLabel = [[TTStyledTextLabel alloc] initWithFrame:CGRectMake(left, top, width - left - padding, 30)];
	[self.view addSubview:_ownerLabel];
	top += 60;
	left = padding;
	
	_privacyHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width - left - padding, 25)];
	_privacyHeaderLabel.font = [UIFont boldSystemFontOfSize:16];
	_privacyHeaderLabel.text = @"Privacy";
	[self.view addSubview:_privacyHeaderLabel];
	top += _privacyHeaderLabel.frame.size.height;
	
	_privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, width - left - padding, 100)];
	_privacyLabel.font = [UIFont systemFontOfSize:16];
	_privacyLabel.lineBreakMode = UILineBreakModeWordWrap;
	_privacyLabel.numberOfLines = 0;
	[self.view addSubview:_privacyLabel];
	top += _privacyLabel.frame.size.height;
	
//	_removeMeButton = [[TTButton buttonWithStyle:@"largeRoundCancelButton:" title:@"Remove Me From Event"] retain];
//	[_removeMeButton sizeToFit];
//	_removeMeButton.frame = CGRectOffset(_removeMeButton.frame, round((self.view.frame.size.width - _removeMeButton.frame.size.width) * 0.5), top);
//	[self.view addSubview:_removeMeButton];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
														initWithTitle:@"Done"
														style:UIBarButtonItemStyleBordered
														target:self action:@selector(dismissModalViewController)] autorelease];
	
	[self updateGroupContent];
}

- (void)viewDidUnload
{
	TT_RELEASE_SAFELY(_group);
	TT_RELEASE_SAFELY(_thumbnailView);
	TT_RELEASE_SAFELY(_titleLabel);
	TT_RELEASE_SAFELY(_ownerLabel);
	TT_RELEASE_SAFELY(_privacyHeaderLabel);
	TT_RELEASE_SAFELY(_privacyLabel);
	TT_RELEASE_SAFELY(_removeMeButton);
	[super viewDidUnload];
}
@end
