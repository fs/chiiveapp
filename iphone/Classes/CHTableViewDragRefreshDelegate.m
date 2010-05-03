//
//  CHThumbsTableViewDragRefreshDelegate.m
//  chiive
//
//  Created by 17FEET on 3/17/10.
//  Copyright 2010 17FEET. All rights reserved.
//

#import "CHTableViewDragRefreshDelegate.h"

@implementation CHTableHeaderDragRefreshView
- (id)initWithFrame:(CGRect)frame {
	if(self = [super initWithFrame:frame]) {
		
		// reposition elements - Handle this in layout subviews!
		_statusLabel.frame = CGRectOffset(_statusLabel.frame, 0, 6);
		_lastUpdatedLabel.hidden = YES;
//		_lastUpdatedLabel.frame = CGRectOffset(_lastUpdatedLabel.frame, 0, -10);
		_activityView.frame = CGRectOffset(_activityView.frame, 6, -8);
		
		// add bottom gradient
		_bottomGradientView = [[TTView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 20.0f,
																	   frame.size.width, 20.0f )];
		_bottomGradientView.style = [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithWhite:0 alpha:0]
																		color2:[UIColor colorWithWhite:0 alpha:.5] 
																		  next:nil];
		_bottomGradientView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
		[self insertSubview:_bottomGradientView atIndex:0];
	}
	return self;
}

- (void)setUpdateDate:(NSDate*)newDate {
	// Update data is hidden
	return;
	
	if (newDate) {
		if (_lastUpdatedDate != newDate) {
			[_lastUpdatedDate release];
		}
		
		_lastUpdatedDate = [newDate retain];
		
		_lastUpdatedLabel.text = [NSString stringWithFormat:
								  TTLocalizedString(@"Updated %@",
													@"The last time the table view was updated."),
								  [_lastUpdatedDate formatRelativeTime]];
		
	} else {
		_lastUpdatedDate = nil;
		_lastUpdatedLabel.text = TTLocalizedString(@"",
												   @"The table view has never been updated");
	}
}

- (void)dealloc {
	TT_RELEASE_SAFELY(_bottomGradientView);
	[super dealloc];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation TTTableViewDragRefreshDelegate (DynamicHeights)
- (UIEdgeInsets)insetsShow
{
	return UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
}
- (UIEdgeInsets)insetsHide
{
	return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}
- (float)refreshDelta
{
	return - (self.insetsShow.top + 5);
}
- (TTTableHeaderDragRefreshView *)createHeaderView
{
	return [[TTTableHeaderDragRefreshView alloc]
			initWithFrame:CGRectMake(0,
									 -_controller.tableView.bounds.size.height,
									 _controller.tableView.width,
									 _controller.tableView.bounds.size.height)];
}
- (id)initWithController:(TTTableViewController*)controller {
	if (self = [super initWithController:controller]) {
		// Add our refresh header
		_headerView = [self createHeaderView];
		_headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_headerView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
		[_controller.tableView addSubview:_headerView];
		
		// Hook up to the model to listen for changes.
		[_controller.model.delegates addObject:self];
		
		// Grab the last refresh date if there is one.
		if ([_controller.model respondsToSelector:@selector(loadedTime)]) {
			NSDate* date = [_controller.model performSelector:@selector(loadedTime)];
			
			if (nil != date) {
				[_headerView setUpdateDate:date];
			}
		}
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
	[super scrollViewDidScroll:scrollView];
	
	if (_isDragging) {
		if (_headerView.isFlipped
			&& scrollView.contentOffset.y > self.refreshDelta
			&& scrollView.contentOffset.y < 0.0f
			&& !_controller.model.isLoading) {
			[_headerView flipImageAnimated:YES];
			[_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
			
		} else if (!_headerView.isFlipped
				   && scrollView.contentOffset.y < self.refreshDelta) {
			[_headerView flipImageAnimated:YES];
			[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
		}
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
	[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
	
	// If dragging ends and we are far enough to be fully showing the header view trigger a
	// load as long as we arent loading already
	if (scrollView.contentOffset.y <= self.refreshDelta && !_controller.model.isLoading) {
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"DragRefreshTableReload" object:nil];
		[_controller.model load:TTURLRequestCachePolicyNetwork more:NO];
	}
	
	_isDragging = NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<TTModel>)model {
	[_headerView showActivity:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
	_controller.tableView.contentInset = self.insetsShow;
	[UIView commitAnimations];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
	[_headerView flipImageAnimated:NO];
	[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
	[_headerView showActivity:NO];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	_controller.tableView.contentInset = self.insetsHide;
	[UIView commitAnimations];
	
	if ([model respondsToSelector:@selector(loadedTime)]) {
		NSDate* date = [model performSelector:@selector(loadedTime)];
		[_headerView setUpdateDate:date];
		
	} else {
		[_headerView setCurrentDate];
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
	[_headerView flipImageAnimated:NO];
	[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
	[_headerView showActivity:NO];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	_controller.tableView.contentInset = self.insetsHide;
	[UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
	[_headerView flipImageAnimated:NO];
	[_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
	[_headerView showActivity:NO];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	_controller.tableView.contentInset = self.insetsHide;
	[UIView commitAnimations];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


@implementation CHTableViewDragRefreshDelegate
- (TTTableHeaderDragRefreshView *)createHeaderView
{
	return [[CHTableHeaderDragRefreshView alloc]
			initWithFrame:CGRectMake(0,
									 -_controller.tableView.bounds.size.height,
									 _controller.tableView.width,
									 _controller.tableView.bounds.size.height)];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showLoading
{
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
	_controller.tableView.contentInset = self.insetsShow;
//	[UIView commitAnimations];
}
- (void)hideLoadingAfterDelay
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:ttkDefaultTransitionDuration];
	[UIView setAnimationDelay:0.3];
	_controller.tableView.contentInset = self.insetsHide;
	[UIView commitAnimations];
}
@end

@implementation CHThumbsTableViewDragRefreshDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
	return tableView.rowHeight;
}

@end
