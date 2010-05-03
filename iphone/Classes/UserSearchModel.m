//
//  UserSearchModel.m
//  spyglass
//
//  Created by 17FEET on 4/2/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "UserSearchModel.h"
#import "User.h"
#import "Global.h"



///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UserSearchModel
@synthesize userModel = _userModel, searchText = _searchText, remote = _remote;

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		_searchDelayTimer = nil;
		_searchDelay = 0.5;
	}
	return self;
}

- (void)dealloc
{
	TT_INVALIDATE_TIMER(_searchDelayTimer);
	TT_RELEASE_SAFELY(_userModel);
	TT_RELEASE_SAFELY(_searchText);
	[super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)search:(NSString*)text
{
	[self.children removeAllObjects];
	self.searchText = text;
	
	if (self.remote)
	{
		TT_INVALIDATE_TIMER(_searchDelayTimer);
		_searchDelayTimer = [NSTimer scheduledTimerWithTimeInterval:_searchDelay target:self
														   selector:@selector(delayedSearchReady:) userInfo:nil repeats:NO];
	}
	else
	{
		[self didStartLoad];
		
		if (text.length) {
			text = [text lowercaseString];
			for (User *user in self.userModel.children) {
				if ([[user.displayName lowercaseString] rangeOfString:text].location == 0) {
					[self.children addObject:user];
				}
			}
		}
		[self didFinishLoad];
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)delayedSearchReady:(NSTimer*)timer {
	_searchDelayTimer = nil;
	[self load:TTURLRequestCachePolicyNone more:NO];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// RESTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more
{
	if (!self.remote || !self.searchText || [self.searchText isEmptyOrWhitespace])
	{
		return;
	}
	else
	{
		[super load:cachePolicy more:more];
	}
}

- (NSString *)childrenURL
{
	return [NSString stringWithFormat:@"%@users.json?q=%@",
			[Global getInstance].sitePath,
			self.searchText
			];
}

// if we're looking for remote friends, do not load saved friends
- (void)loadSavedFriends
{
	if (!self.remote)
		[super loadSavedFriends];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (BOOL)isLoading {
	return !!_searchDelayTimer || [super isLoading];
}

- (void)cancel {
	if (_searchDelayTimer)
	{
		TT_INVALIDATE_TIMER(_searchDelayTimer);
		[self didCancelLoad];
	}
	else
	{
		[super cancel];
	}
}
@end
