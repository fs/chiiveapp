//
//  CHAvatarView.h
//  chiive
//
//  Created by Arrel Gray on 3/20/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@class User;

@interface CHAvatarView : UIView {
	UIView				*_avatarBackground;
	TTImageView			*_avatarImageView;
}

@property (nonatomic, copy)		NSString		*urlPath;
@property (nonatomic, readonly)	UIView			*avatarBackground;
@property (nonatomic, readonly)	TTImageView		*avatarImageView;

@end
