//
//  FTTextInputBar.h
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@class FTTextInputField;

@interface FTTextInputBar : TTView {
	FTTextInputField	*_textField;
	TTView				*_boxView;
	UIColor				*_tintColor;
	TTStyle				*_textFieldStyle;
	TTButton			*_cancelButton;
	BOOL				_showsCancelButton;
}

@property(nonatomic,assign) id<UITextFieldDelegate> delegate;
@property(nonatomic,copy) NSString* text;
@property(nonatomic,copy) NSString* placeholder;
@property(nonatomic,readonly) TTView* boxView;
@property(nonatomic,retain) UIColor* tintColor;
@property(nonatomic,retain) UIColor* textColor;
@property(nonatomic,retain) UIFont* font;
@property(nonatomic,retain) TTStyle* textFieldStyle;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;
@property(nonatomic) CGFloat rowHeight;
@property(nonatomic, readonly) BOOL editing;
@property(nonatomic) BOOL showsCancelButton;
@property(nonatomic) BOOL showsDarkScreen;
@property(nonatomic, readonly) BOOL hasText;

@end
