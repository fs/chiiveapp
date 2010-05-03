//
//  CHTableEmptyView.h
//  spyglass
//
//  Created by 17FEET on 4/1/10.
//  Copyright 2010 17FEET. All rights reserved.
//

@interface CHTableEmptyView : UIView {
	TTButton		*_button;
	TTLabel			*_titleLabel;
	TTLabel			*_messageLabel;
}

@property (nonatomic, readonly)	TTButton		*button;
@property (nonatomic, readonly)	TTLabel			*titleLabel;
@property (nonatomic, readonly)	TTLabel			*messageLabel;

@end
