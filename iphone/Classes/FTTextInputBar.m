//
//  FTTextInputBar.m
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "FTTextInputBar.h"
#import "FTTextInputField.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kMarginX = 5;  
static const CGFloat kMarginY = 7;
static const CGFloat kPaddingX = 10;
static const CGFloat kPaddingY = 10;
static const CGFloat kSpacingX = 4;
static const CGFloat kButtonSpacing = 12;
static const CGFloat kButtonHeight = 30;

static const CGFloat kIndexViewMargin = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////



@implementation FTTextInputBar
@synthesize boxView = _boxView, tintColor = _tintColor, textFieldStyle = _textFieldStyle,
showsCancelButton = _showsCancelButton;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (CGFloat)indexViewWidth {
	UITableView* tableView = (UITableView*)[self ancestorOrSelfWithClass:[UITableView class]];
	if (tableView) {
		UIView* indexView = tableView.indexView;
		if (indexView) {
			return indexView.width;
		}
	}
	return 0;
}

- (void)showIndexView:(BOOL)show {
	UITableView* tableView = (UITableView*)[self ancestorOrSelfWithClass:[UITableView class]];
	if (tableView) {
		UIView* indexView = tableView.indexView;
		if (indexView) {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:TT_TRANSITION_DURATION];
			
			if (show) {
				CGRect frame = indexView.frame;
				frame.origin.x = self.width - (indexView.width + kIndexViewMargin);
				indexView.frame = frame;
			} else {
				indexView.frame = CGRectOffset(indexView.frame, indexView.width + kIndexViewMargin, 0);
			}
			indexView.alpha = show ? 1 : 0;
			
			CGRect searchFrame = _textField.frame;
			searchFrame.size.width += show ? -self.indexViewWidth : self.indexViewWidth;
			_textField.frame = searchFrame;
			
			CGRect boxFrame = _boxView.frame;
			boxFrame.size.width += show ? -self.indexViewWidth : self.indexViewWidth;
			_boxView.frame = boxFrame;
			
			[UIView commitAnimations];
		}
	}
}

- (void)scrollToTop {
	UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
	if (scrollView) {
		CGPoint offset = scrollView.contentOffset;
		CGPoint myOffset = [self offsetFromView:scrollView];
		if (offset.y != myOffset.y) {
			[scrollView setContentOffset:CGPointMake(offset.x, myOffset.y) animated:YES];
		}
	}
}

- (void)textFieldDidBeginEditing {
	[self scrollToTop];
	[self showIndexView:NO];
}

- (void)textFieldDidEndEditing {
	[self showIndexView:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_boxView = [[TTView alloc] init];
		_boxView.backgroundColor = [UIColor clearColor];
		[self addSubview:_boxView];
        
		_textField = [[FTTextInputField alloc] init];
		_textField.placeholder = TTLocalizedString(@"Type Here", @"");
		_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[_textField addTarget:self action:@selector(textFieldDidBeginEditing)
			   forControlEvents:UIControlEventEditingDidBegin];
		[_textField addTarget:self action:@selector(textFieldDidEndEditing)
			   forControlEvents:UIControlEventEditingDidEnd];
		[self addSubview:_textField];
		
		self.tintColor = TTSTYLEVAR(searchBarTintColor);
		self.style = TTSTYLE(searchBar);
		self.textFieldStyle = TTSTYLE(searchTextField);
		self.font = TTSTYLEVAR(font);
		self.showsCancelButton = NO;
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_textField);
	TT_RELEASE_SAFELY(_boxView);
	TT_RELEASE_SAFELY(_textFieldStyle);
	TT_RELEASE_SAFELY(_tintColor);
	TT_RELEASE_SAFELY(_cancelButton);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (BOOL)becomeFirstResponder {
	return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	return [_textField resignFirstResponder];
}
- (BOOL)cancelEditing {
	_textField.text = @"";
	return [_textField resignFirstResponder];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)layoutSubviews {
	CGFloat indexViewWidth = [_textField isEditing] ? 0 : self.indexViewWidth;
	CGFloat leftPadding = kSpacingX;
	
	CGFloat buttonWidth = 0;
	if (_showsCancelButton) {
		[_cancelButton sizeToFit];
		buttonWidth = _cancelButton.width + kButtonSpacing;
	}
	
	CGFloat boxHeight = self.font.leading + 8;
	_boxView.frame = CGRectMake(kMarginX, floor(self.height/2 - boxHeight/2),
								self.width - (kMarginX*2 + indexViewWidth + buttonWidth), boxHeight);
    
	_textField.frame = CGRectMake(kMarginX+kPaddingX+leftPadding, 0,
									self.width - (kMarginX*2+kPaddingX+leftPadding+buttonWidth+indexViewWidth), self.height);
	
	if (_showsCancelButton) {
		_cancelButton.frame = CGRectMake(_boxView.right + kButtonSpacing,
										 floor(self.height/2 - kButtonHeight/2),
										 _cancelButton.width, kButtonHeight);
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat height = self.font.leading+kPaddingY*2;
	if (height < TT_ROW_HEIGHT) {
		height = TT_ROW_HEIGHT;
	}
	return CGSizeMake(size.width, height);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (id<UITextFieldDelegate>)delegate {
	return _textField.delegate;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
	_textField.delegate = delegate;
}

- (BOOL)editing {
	return _textField.editing;
}


- (BOOL)showsDarkScreen {
	return _textField.showsDarkScreen;
}

- (void)setShowsDarkScreen:(BOOL)showsDarkScreen {
	_textField.showsDarkScreen = showsDarkScreen;
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton {
	if (showsCancelButton != _showsCancelButton) {
		_showsCancelButton = showsCancelButton;
		
		if (_showsCancelButton) {
			_cancelButton = [[TTButton buttonWithStyle:@"blackToolbarButton:"
												 title:TTLocalizedString(@"Cancel", @"")] retain];
			[_cancelButton addTarget:self action:@selector(cancelEditing)
					forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:_cancelButton];
		} else {
			[_cancelButton removeFromSuperview];
			TT_RELEASE_SAFELY(_cancelButton);
		}
	}
}

- (NSString*)text {
	return _textField.text;
}

- (void)setText:(NSString*)text {
	_textField.text = text;
}

- (NSString*)placeholder {
	return _textField.placeholder;
}

- (void)setPlaceholder:(NSString*)placeholder {
	_textField.placeholder = placeholder;
}

- (void)setTintColor:(UIColor*)tintColor {
	if (tintColor != _tintColor) {
		[_tintColor release];
		_tintColor = [tintColor retain];
	}
}

- (void)setTextFieldStyle:(TTStyle*)textFieldStyle {
	if (textFieldStyle != _textFieldStyle) {
		[_textFieldStyle release];
		_textFieldStyle = [textFieldStyle retain];
		_boxView.style = _textFieldStyle;
	}
}

- (UIColor*)textColor {
	return _textField.textColor;
}

- (void)setTextColor:(UIColor*)textColor {
	_textField.textColor = textColor;
}

- (UIFont*)font {
	return _textField.font;
}

- (void)setFont:(UIFont*)font {
	_textField.font = font;
}

- (CGFloat)rowHeight {
	return _textField.rowHeight;
}

- (void)setRowHeight:(CGFloat)rowHeight {
	_textField.rowHeight = rowHeight;
}

- (UIReturnKeyType)returnKeyType {
	return _textField.returnKeyType;
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
	_textField.returnKeyType = returnKeyType;
}

- (BOOL)enablesReturnKeyAutomatically {
	return _textField.enablesReturnKeyAutomatically;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically {
	_textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)hasText {
	return _textField.hasText;
}
@end
