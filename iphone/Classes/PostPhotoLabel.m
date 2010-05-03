//
//  PostPhotoLabel.m
//  chiive
//
//  Created by 17FEET on 9/22/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "PostPhotoLabel.h"
#import "CommentsButtonView.h"
#import "Post.h"
#import "Global.h"
#import "User.h"
#import "CHDefaultStyleSheet.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static NSInteger kPadding = 5;

///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation PostPhotoLabel
@synthesize post = _post;

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setCaption:(NSString *)caption
{
	if (!caption || [caption isEmptyOrWhitespace])
	{
		_captionLabel.textColor = RGBCOLOR(117,117,117);
		//_captionLabel.text = [[Global getInstance].currentUserId isEqualToString:self.post.userUUID] ? @"Click to add caption" : @"No caption";
		_captionLabel.text = @"No caption";
	}
	else
	{
		_captionLabel.textColor = RGBCOLOR(200,200,200);
		_captionLabel.text = caption;
	}
}

- (void)setPost:(Post *)post {
	if (post != _post) {
		[post retain];
		[_post release];
		_post = post;
		
		if (post.user == nil)
			_userNameLabel.text = @"Anonymous";
		else if (post.user.UUID == [Global getInstance].currentUserId)
			_userNameLabel.text = @"Me";
		else
			_userNameLabel.text = post.user.displayName;
		
		[self setCaption:post.caption];
		
		_avatarImageView.defaultImage = [UIImage imageNamed:@"icon_person.png"];
		_avatarImageView.urlPath = post.user ? post.user.URLForAvatar : nil;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoView

- (CGRect)captionFrame
{
	return _captionLabel.frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init
{
	if (self = [super init])
	{
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
		
		NSInteger avatarSize = TT_TOOLBAR_HEIGHT - kPadding * 2;;
		
		UIView *avatarBackground = [[[UIView alloc] initWithFrame:CGRectMake(kPadding - 1, kPadding - 1, avatarSize + 2, avatarSize + 2)] autorelease];
		avatarBackground.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
		[self addSubview:avatarBackground];
		
		_avatarImageView = [[TTImageView alloc] initWithFrame:CGRectMake(kPadding, kPadding, avatarSize, avatarSize)];
		[self addSubview:_avatarImageView];
		
		_userNameLabel = [[UILabel alloc] init];
		_userNameLabel.font = [UIFont boldSystemFontOfSize:14];
		_userNameLabel.textColor = [UIColor whiteColor];
		_userNameLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_userNameLabel];
		
		_captionLabel = [[UILabel alloc] init];
		_captionLabel.font = [UIFont systemFontOfSize:13];
		_captionLabel.textColor = RGBCOLOR(117,117,117);
		_captionLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_captionLabel];
		
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
	NSInteger left = _avatarImageView.frame.origin.x + _avatarImageView.frame.size.width + kPadding * 2;
	NSInteger top = kPadding - 1;
	
	_userNameLabel.frame = CGRectMake(left, 
									  top,
									  self.width - left - kPadding * 2,
									  [_userNameLabel.text sizeWithFont:_userNameLabel.font].height);
	top += _userNameLabel.frame.size.height;
	_captionLabel.frame = CGRectMake(left, 
									 top,
									 _userNameLabel.frame.size.width, 
									 [_captionLabel.text sizeWithFont:_captionLabel.font].height);
	[super layoutSubviews];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// Accessors

- (void)dealloc
{
	[_post release];
	[_avatarImageView release];
	[_userNameLabel release];
	[_captionLabel release];
	[super dealloc];
}

@end
