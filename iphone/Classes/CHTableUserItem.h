//
//  CHTableUserItem.h
//  chiive
//
//  Created by 17FEET on 2/26/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class User;




///////////////////////////////////////////////////////////////////////////////////////////////////
// Chiive user (default user display item)

@interface CHTableUserItem : TTTableSubtitleItem {
	NSString		*_accessoryText;
	NSInteger		_numberOfPhotos;
	NSInteger		_padding;
}
@property (nonatomic, copy)		NSString	*accessoryText;
@property (nonatomic, assign)	NSInteger	numberOfPhotos;
@property (nonatomic, assign)	NSInteger		padding;

+ (id)itemWithUser:(User *)user;
+ (id)itemWithUser:(User *)user URL:(NSString*)URL;
+ (id)itemWithUser:(User *)user URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface CHTableUserItemCell : TTTableSubtitleItemCell
@end





///////////////////////////////////////////////////////////////////////////////////////////////////
// Chiive user request field (displayed in Requests page of friends list)

@interface CHTableUserRequestItem : TTTableSubtitleItem {
	NSString		*_accessoryText;
}
@property (nonatomic, copy)	NSString	*accessoryText;
+ (id)itemWithUser:(User *)user;
+ (id)itemWithUser:(User *)user URL:(NSString*)URL;
+ (id)itemWithUser:(User *)user URL:(NSString*)URL accessoryURL:(NSString*)accessoryURL;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@interface CHTableUserRequestItemCell : TTTableSubtitleItemCell
{
	TTButton	*_leftButton;
	TTButton	*_rightButton;
	NSString	*_leftUrlPath;
	NSString	*_rightUrlPath;
}
@property (nonatomic, retain)	TTButton	*leftButton;
@property (nonatomic, retain)	TTButton	*rightButton;
@property (nonatomic, assign)	NSString	*leftUrlPath;
@property (nonatomic, assign)	NSString	*rightUrlPath;
@end




///////////////////////////////////////////////////////////////////////////////////////////////////
// Contact from address book for inviting to Chiive

@interface CHTableUserInviteItem : TTTableSubtitleItem {
	BOOL	_checked;
}
@property (nonatomic, assign) BOOL checked;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@interface CHTableUserInviteItemCell : TTTableSubtitleItemCell
@end