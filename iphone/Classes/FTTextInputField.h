//
//  FTTextInputField.h
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//



@interface FTTextInputField : UITextField {
	TTView			*_shadowView;
	UIButton		*_screenView;
	CGFloat			_rowHeight;
//	BOOL			_showsDoneButton;
	BOOL			_showsDarkScreen;
}

@property(nonatomic) CGFloat rowHeight;
@property(nonatomic,readonly) BOOL hasText;
@property(nonatomic) BOOL showsDarkScreen;

/*
- (void)search;

- (void)showSearchResults:(BOOL)show;
*/
- (UIView*)superviewForSearchResults;

- (CGRect)rectForSearchResults:(BOOL)withKeyboard;

- (BOOL)shouldUpdate:(BOOL)emptyText;

@end
