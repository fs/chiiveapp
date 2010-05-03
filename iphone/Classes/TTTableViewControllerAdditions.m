//
//  TTTableViewControllerAdditions.m
//  chiive
//
//  Created by 17FEET on 2/22/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "TTTableViewControllerAdditions.h"


@interface TTTableViewController (Private)
- (void)layoutOverlayView;
- (void)layoutBannerView;
- (void)insetTableViewFull;
- (void)cancelInsetTableViewFull;
- (void)cancelInsetTableViewFullDelayed;
@end

@implementation TTTableViewController (CHCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (void)insetTableViewFull
{
	[self cancelInsetTableViewFullDelayed];
	
//	[UIView beginAnimations:nil context:self.tableView];
//	[UIView setAnimationDuration:TT_TRANSITION_DURATION];
	self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top,
												   self.tableView.contentInset.left, 
												   0,
												   self.tableView.contentInset.right);
//	[UIView commitAnimations];
}

- (void)cancelInsetTableViewFullDelayed
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(insetTableViewFull) object:nil];
}

- (void)insetTableViewFullDelayed
{
	[self performSelector:@selector(insetTableViewFull) withObject:nil afterDelay:0.1];
}	


///////////////////////////////////////////////////////////////////////////////////////////////////
// keyboard autoscroll fixes - use insets rather than frame resizing

- (void)setAutoresizesForKeyboard:(BOOL)autoresizesForKeyboard
{
	if (autoresizesForKeyboard != _autoresizesForKeyboard) {
		_autoresizesForKeyboard = autoresizesForKeyboard;
		
		if (_autoresizesForKeyboard)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(keyboardWillShow:)
														 name:UIKeyboardWillShowNotification
													   object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(keyboardDidShow:)
														 name:UIKeyboardDidShowNotification
													   object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(keyboardWillHide:)
														 name:UIKeyboardWillHideNotification
													   object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(keyboardDidHide:)
														 name:UIKeyboardDidHideNotification
													   object:nil];
		} else {
			[[NSNotificationCenter defaultCenter] removeObserver:self
															name:@"UIKeyboardWillShowNotification" object:nil];
			[[NSNotificationCenter defaultCenter] removeObserver:self
															name:@"UIKeyboardDidShowNotification" object:nil];
			[[NSNotificationCenter defaultCenter] removeObserver:self
															name:@"UIKeyboardWillHideNotification" object:nil];
			[[NSNotificationCenter defaultCenter] removeObserver:self
															name:@"UIKeyboardDidHideNotification" object:nil];
		}
	}
}


- (void)keyboardWillShow:(NSNotification *)aNotification {
	if (_isViewAppearing)
		[self cancelInsetTableViewFullDelayed];
}

- (void)keyboardDidShow:(NSNotification *)aNotification {
	if (_isViewAppearing)
	{
		[self cancelInsetTableViewFullDelayed];
		self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, TTKeyboardHeight(), 0);
		[self.tableView scrollFirstResponderIntoView];
	}
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
	if (_isViewAppearing)
		[self insetTableViewFullDelayed];
}

- (void)keyboardDidHide:(NSNotification *)aNotification {
	if (_isViewAppearing)
		[self insetTableViewFull];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// overrides

- (void)didSelectAccessoryButtonForObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
}

// override any automatic model loading
//- (BOOL)shouldLoad {
//	return NO; // !self.model.isLoaded;
//}
//
//// override any automatic model loading
//- (BOOL)shouldReload {
//	return NO; // !_modelError && self.model.isOutdated;
//}
//
@end
