//
//  CHTutorialView.h
//  spyglass
//
//  Created by 17FEET on 4/13/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@interface CHTutorialView : UIView {
	UILabel			*_titleLabel;
	UILabel			*_messageLabel;
	UIImageView		*_backgroundView;
	TTButton		*_actionButton;
}

@property (nonatomic, readonly)	float			actionButtonWidth;

@property (nonatomic, readonly)	UILabel			*titleLabel;
@property (nonatomic, readonly)	UILabel			*messageLabel;
@property (nonatomic, readonly)	UIImageView		*backgroundView;
@property (nonatomic, readonly)	TTButton		*actionButton;

- (void)createSubviews;

@end
