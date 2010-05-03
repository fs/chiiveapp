//
//  PostInfoView.m
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "PostInfoView.h"
#import "Post.h"
#import "User.h"
#import "Global.h"

////////////////////////////////////////////////////////////////////////////////////

static CGFloat kPadding = 10;

////////////////////////////////////////////////////////////////////////////////////

@implementation PostInfoView
@synthesize post = _post;

////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)updateInfo
{
	_thumbView.urlPath = [self.post URLForVersion:TTPhotoVersionThumbnail];
	
	_dateLabel.text = [self.post.captured_at formatRelativeTime];
	
	// author button disabled for now
	if (YES || !self.post.user || self.post.user == [Global getInstance].currentUser)
	{
		[_authorButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		_authorButton.enabled = NO;
	}
	else
	{
		[_authorButton setTitleColor:TTSTYLEVAR(linkTextColor) forState:UIControlStateNormal];
		_authorButton.enabled = YES;
	}
	
	if (!self.post.user)
		[_authorButton setTitle:@"Anonymous" forState:UIControlStateNormal];
	else if (self.post.user != [Global getInstance].currentUser)
		[_authorButton setTitle:self.post.user.displayName forState:UIControlStateNormal];
	else
		[_authorButton setTitle:@"Me" forState:UIControlStateNormal];
	
//	BOOL editDisabled = self.post.user != [Global getInstance].currentUser;
//	_editButton.hidden = editDisabled;
//	_separatorLabel.hidden = editDisabled;
//	_deleteButton.hidden = editDisabled;
	
	if (!!self.post.caption && ![self.post.caption isEmptyOrWhitespace])
	{
		_captionLabel.text = self.post.caption;
		_captionLabel.textColor = [UIColor darkGrayColor];
	}
	else
	{
		_captionLabel.text = @"No caption";
		_captionLabel.textColor = [UIColor grayColor];
	}
	
	_commentsLabel.text = [NSString stringWithFormat:@"%d Comments", self.post.commentModel.numberOfChildren];
}

////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPost:(Post *)post
{
	if (post != _post)
	{
		[post retain];
		[_post release];
		_post = post;
		
		if (!!_post)
			[self updateInfo];
	}
}

- (UIButton *)authorButton
{
	if (!_authorButton)
	{
		_authorButton = [[UIButton alloc] initWithFrame:CGRectZero];
		_authorButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
		[self addSubview:_authorButton];
	}
	return _authorButton;
}

- (UIButton *)editButton
{
	if (!_editButton)
	{
		_editButton = [[UIButton alloc] initWithFrame:CGRectZero];
		_editButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
		[_editButton setTitleColor:TTSTYLEVAR(linkTextColor) forState:UIControlStateNormal];
		[_editButton setTitle:@"Edit Caption" forState:UIControlStateNormal];
		[self addSubview:_editButton];
	}
	return _editButton;
}

- (UIButton *)deleteButton
{
	if (!_deleteButton)
	{
		_deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
		_deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
		[_deleteButton setTitleColor:TTSTYLEVAR(linkTextColor) forState:UIControlStateNormal];
		[_deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
		[self addSubview:_deleteButton];
	}
	return _deleteButton;
}



////////////////////////////////////////////////////////////////////////////////////
// UIView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor whiteColor];
		
		_thumbView = [[TTImageView alloc] initWithFrame:CGRectZero];
		_thumbView.backgroundColor = [UIColor whiteColor];
		[self addSubview:_thumbView];
		
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_dateLabel.textColor = [UIColor grayColor];
		_dateLabel.font = [UIFont systemFontOfSize:13];
		_dateLabel.text = @"Date here";
		[self addSubview:_dateLabel];
		
		_photoByLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_photoByLabel.textColor = [UIColor grayColor];
		_photoByLabel.font = [UIFont systemFontOfSize:13];
		_photoByLabel.text = @"Photo By:";
		[self addSubview:_photoByLabel];
		
		self.authorButton;
//		self.editButton;
//		self.deleteButton;
		
//		_separatorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//		_separatorLabel.textColor = [UIColor grayColor];
//		_separatorLabel.font = [UIFont boldSystemFontOfSize:13];
//		_separatorLabel.text = @"|";
//		[self addSubview:_separatorLabel];
		
		_captionSeparatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui_post_info_caption_separator.png"]];
		[self addSubview:_captionSeparatorView];
		
		_captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_captionLabel.numberOfLines = 0;
		_captionLabel.lineBreakMode = UILineBreakModeWordWrap;
		_captionLabel.font = [UIFont systemFontOfSize:15];
		_captionLabel.textColor = [UIColor darkGrayColor];
		_captionLabel.text = @"Caption here";
		[self addSubview:_captionLabel];
		
		_commentsBubble = [[TTLabel alloc] init];
		_commentsBubble.style = TTSTYLE(commentBubble);
		_commentsBubble.text = @"  ";
		_commentsBubble.backgroundColor = [UIColor whiteColor];
		[self addSubview:_commentsBubble];
		
		_commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		_commentsLabel.font = [UIFont boldSystemFontOfSize:13];
		_commentsLabel.text = @"Comments here";
		[self addSubview:_commentsLabel];
		
		_borderBottomView = [[TTView alloc] initWithFrame:CGRectZero];
		_borderBottomView.style = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithWhite:0.85 alpha:1] color2:[UIColor colorWithWhite:0.95 alpha:1] next:nil];
		[self addSubview:_borderBottomView];
	}
	
	return self;
}

- (void)layoutSubviews
{
	NSInteger thumbWidth = 75;
	NSInteger left = kPadding;
	NSInteger top = kPadding;
	
	_thumbView.frame = CGRectMake(left, top, thumbWidth, thumbWidth);
	left += thumbWidth + kPadding;
	top += kPadding;
	
	_dateLabel.frame = CGRectMake(left, top, self.width - left - kPadding, _dateLabel.font.ttLineHeight);
	top += _dateLabel.height;
	
	_photoByLabel.frame = CGRectMake(left, top, self.width - left - kPadding, _photoByLabel.font.ttLineHeight);
	left += [_photoByLabel.text sizeWithFont:_photoByLabel.font].width + 3;
	
	NSInteger authorButtonWidth = [[_authorButton titleForState:UIControlStateNormal] sizeWithFont:_authorButton.titleLabel.font].width;
	_authorButton.frame = CGRectMake(left, top, authorButtonWidth, _authorButton.titleLabel.font.ttLineHeight);
	left = kPadding + thumbWidth + kPadding;
	top += _authorButton.height;
	
//	if (!_editButton.hidden)
//	{
//		NSInteger btnWidth = [[_editButton titleForState:UIControlStateNormal] sizeWithFont:_editButton.titleLabel.font].width;
//		_editButton.frame = CGRectMake(left, top, btnWidth, _editButton.titleLabel.font.ttLineHeight);
//		left += btnWidth + 3;
//		
//		[_separatorLabel sizeToFit];
//		_separatorLabel.frame = CGRectMake(left, top, _separatorLabel.width, _separatorLabel.height);
//		left += _separatorLabel.width + 3;
//		
//		btnWidth = [[_deleteButton titleForState:UIControlStateNormal] sizeWithFont:_deleteButton.titleLabel.font].width;
//		_deleteButton.frame = CGRectMake(left, top, btnWidth, _deleteButton.titleLabel.font.ttLineHeight);
//		
//		top += _editButton.height;
//		left = kPadding + thumbWidth + kPadding;
//	}
//	
	_captionSeparatorView.frame = CGRectMake(left, top, _captionSeparatorView.width, _captionSeparatorView.height);
	top += _captionSeparatorView.height;
	
	CGSize labelSize = [_captionLabel sizeThatFits:CGSizeMake(self.width - left - kPadding, 1000)];
	_captionLabel.frame = CGRectMake(left, top, self.width - left - kPadding, labelSize.height);
	top += _captionLabel.height + kPadding;
	
	if (top < _thumbView.bottom)
		top = _thumbView.bottom + 5;
	
	[_commentsBubble sizeToFit];
	_commentsBubble.frame = CGRectMake(kPadding, top, _commentsBubble.width, _commentsBubble.height);
	
	[_commentsLabel sizeToFit];
	_commentsLabel.frame = CGRectMake(kPadding * 2 + _commentsBubble.width, top, _commentsLabel.width, _commentsLabel.height);
	top += _commentsLabel.height + kPadding;
	
	_borderBottomView.frame = CGRectMake(0, top, self.width, 5);
	top += 5;
	
	// update this view's frame
	self.frame = CGRectMake(0, 0, self.width, top);
	[super layoutSubviews];
	
	// reposition within the table view
	UITableView *tableView = (UITableView *)[self superview];
	[tableView setTableHeaderView:self];
}



////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (void)dealloc
{
	TT_RELEASE_SAFELY(_post);
	TT_RELEASE_SAFELY(_thumbView);
	TT_RELEASE_SAFELY(_dateLabel);
	TT_RELEASE_SAFELY(_photoByLabel);
	TT_RELEASE_SAFELY(_authorButton);
	TT_RELEASE_SAFELY(_editButton);
	TT_RELEASE_SAFELY(_separatorLabel);
	TT_RELEASE_SAFELY(_deleteButton);
	TT_RELEASE_SAFELY(_captionSeparatorView);
	TT_RELEASE_SAFELY(_captionLabel);
	TT_RELEASE_SAFELY(_commentsBubble);
	TT_RELEASE_SAFELY(_commentsLabel);
	TT_RELEASE_SAFELY(_borderBottomView);
	
	[super dealloc];
}

@end
