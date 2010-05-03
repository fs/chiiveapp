//
//  FTTextInputField.m
//  chiive
//
//  Created by 17FEET on 12/9/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "FTTextInputField.h"


///////////////////////////////////////////////////////////////////////////////////////////////////

static const CGFloat kShadowHeight = 24;
static const CGFloat kDesiredTableHeight = 150;

///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation FTTextInputField

@synthesize rowHeight = _rowHeight, showsDarkScreen = _showsDarkScreen;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_shadowView = nil;
		_screenView = nil;
		_rowHeight = 0;
		_showsDarkScreen = NO;
		
		self.autocorrectionType = UITextAutocorrectionTypeNo;
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.clearButtonMode = UITextFieldViewModeWhileEditing;
		
		[self addTarget:self action:@selector(didBeginEditing)
	   forControlEvents:UIControlEventEditingDidBegin];
		[self addTarget:self action:@selector(didEndEditing)
	   forControlEvents:UIControlEventEditingDidEnd];
	}
	return self;
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_shadowView);
	TT_RELEASE_SAFELY(_screenView);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)showDarkScreen:(BOOL)show {
	if (show && !_screenView) {
		_screenView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_screenView.backgroundColor = TTSTYLEVAR(screenBackgroundColor);
		_screenView.frame = [self rectForSearchResults:NO];
		_screenView.alpha = 0;
		[_screenView addTarget:self action:@selector(doneAction)
			  forControlEvents:UIControlEventTouchUpInside];
	}
	
	if (show) {
		[self.superviewForSearchResults addSubview:_screenView];
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:TT_TRANSITION_DURATION];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(screenAnimationDidStop)];
	
	_screenView.alpha = show ? 1 : 0;
	
	[UIView commitAnimations];
}

- (NSString*)searchText {
	if (!self.hasText) {
		return @"";
	} else {
		NSCharacterSet* whitespace = [NSCharacterSet whitespaceCharacterSet];
		return [self.text stringByTrimmingCharactersInSet:whitespace];
	}
}


- (void)dispatchUpdate:(NSTimer*)timer {
//	_searchTimer = nil;
//	[self autoSearch];
}

- (void)delayedUpdate {
//	[_searchTimer invalidate];
//	_searchTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self
//												  selector:@selector(dispatchUpdate:) userInfo:nil repeats:NO];
}

- (void)screenAnimationDidStop {
	if (_screenView.alpha == 0) {
		[_screenView removeFromSuperview];
	}
}

- (void)doneAction {
	[self resignFirstResponder];
	
//	if (self.dataSource) {
//		self.text = @"";
//	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// UIControlEvents

- (void)didBeginEditing {
//	if (_dataSource) {
		UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
		scrollView.scrollEnabled = NO;
		scrollView.scrollsToTop = NO;
		
		if (_showsDarkScreen) {
			[self showDarkScreen:YES];
		}
//		if (self.hasText && self.hasSearchResults) {
//			[self showSearchResults:YES];
//		}
//	}
}

- (void)didEndEditing {
//	if (_dataSource) {
		UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
		scrollView.scrollEnabled = YES;
		scrollView.scrollsToTop = YES;
		
//		[self showSearchResults:NO];
		
		if (_showsDarkScreen) {
			[self showDarkScreen:NO];
		}
//	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (BOOL)hasText {
	return self.text.length;
}

/*
- (void)search {
	if (_dataSource) {
		NSString* text = self.searchText;
		[_dataSource search:text];
	}
}

- (void)showSearchResults:(BOOL)show {
	if (show && _dataSource) {
		self.tableView;
		
		if (!_shadowView) {
			_shadowView = [[TTView alloc] init];
			_shadowView.style = TTSTYLE(searchTableShadow);
			_shadowView.backgroundColor = [UIColor clearColor];
			_shadowView.userInteractionEnabled = NO;
		}
		
		if (!_tableView.superview) {
			_tableView.frame = [self rectForSearchResults:YES];
			_shadowView.frame = CGRectMake(_tableView.left, _tableView.top-1,
										   _tableView.width, kShadowHeight);
			
			UIView* superview = self.superviewForSearchResults;
			[superview addSubview:_tableView];
			
			if (_tableView.separatorStyle != UITableViewCellSeparatorStyleNone) {
				[superview addSubview:_shadowView];
			}
		}
		
		[_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:NO];
	} else {
		[_tableView removeFromSuperview];
		[_shadowView removeFromSuperview];
	}
}
 */

- (UIView*)superviewForSearchResults {
	UIScrollView* scrollView = (UIScrollView*)[self ancestorOrSelfWithClass:[UIScrollView class]];
	if (scrollView) {
		return scrollView;
	} else {
		for (UIView* view = self.superview; view; view = view.superview) {
			if (view.height > kDesiredTableHeight) {
				return view;
			}
		}
		
		return self.superview;
	}
}


- (CGRect)rectForSearchResults:(BOOL)withKeyboard {
	UIView* superview = self.superviewForSearchResults;
	
	CGFloat y = 0;
	UIView* view = self;
	while (view != superview) {
		y += view.top;
		view = view.superview;
	}  
	
	CGFloat height = self.height;
	CGFloat keyboardHeight = withKeyboard ? TTKeyboardHeight() : 0;
	CGFloat tableHeight = self.window.height - (self.screenViewY + height + keyboardHeight);
    
	return CGRectMake(0, y + self.height-1, superview.frame.size.width, tableHeight+1);
}


- (BOOL)shouldUpdate:(BOOL)emptyText {
	[self delayedUpdate];
	return YES;
}


@end
