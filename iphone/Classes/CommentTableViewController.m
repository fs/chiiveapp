//
//  CommentTableViewController.m
//  chiive
//
//  Created by 17FEET on 12/4/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CommentTableViewController.h"
#import "FTTextInputBar.h"
#import "CHTableCommentItem.h"
#import "CommentModel.h"
#import "Comment.h"
#import "Post.h"
#import "User.h"


////////////////////////////////////////////////////////////////////////////////////

@implementation CommentListDataSource
- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object;
{
	if ([object isKindOfClass:[CHTableCommentItem class]])
		return [CHTableCommentItemCell class];
	else
		return [super tableView:tableView cellClassForObject:object];
}

- (CHTableCommentItem *)itemForObject:(Comment *)comment
{
	TTStyledText* text = [TTStyledText textFromXHTML:[NSString stringWithFormat:@"<b><span class=\"userName\">%@</span></b> %@", 
													  comment.user.displayName, 
													  comment.body]];
	
	CHTableCommentItem *item = [[[CHTableCommentItem alloc] init] autorelease];
	item.text = text;
	item.imageURL = [comment.user URLForAvatar];
	return item;
}

- (void)tableViewDidLoadModel:(UITableView *)tableView
{
    [super tableViewDidLoadModel:tableView];
    [self.items removeAllObjects];
    
	CommentModel *commentModel = [(Post *)self.model commentModel];
	NSInteger i = 0;
	
    for (Comment *child in [commentModel children])
	{
		CHTableCommentItem *item = [self itemForObject:child];
		if (++i % 2)
			item.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
		else
			item.backgroundColor = [UIColor whiteColor];
		
        [self.items addObject:item];
	}
}

- (NSIndexPath*)tableView:(UITableView*)tableView willInsertObject:(id)object
			  atIndexPath:(NSIndexPath*)indexPath
{
	if ([object isKindOfClass:[Comment class]])
		return [super tableView:tableView willInsertObject:[self itemForObject:(Comment *)object] atIndexPath:indexPath];
	else
		return nil;
}
@end

////////////////////////////////////////////////////////////////////////////////////



@implementation CommentTableViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (FTTextInputBar *)commentField
{
	if (nil == _commentField)
	{
		NSInteger tabBarHeight = TT_TOOLBAR_HEIGHT;
		CGRect fullFrame = CGRectInset(TTApplicationFrame(), 0, TT_TOOLBAR_HEIGHT);// TTBarsHeight());
		
		// create the field
		_commentField = [[FTTextInputBar alloc] initWithFrame:CGRectMake(fullFrame.origin.x,
																		 fullFrame.origin.y + fullFrame.size.height - tabBarHeight, 
																		 fullFrame.size.width, tabBarHeight)];
		_commentField.showsCancelButton = YES;
		_commentField.returnKeyType = UIReturnKeySend;
		_commentField.enablesReturnKeyAutomatically = YES;
		_commentField.placeholder = @"Add a comment";
		_commentField.delegate = self;
		
		//add the listener to move up with the keyboard
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	}
	
	return _commentField;
}

- (Post *)post
{
	return (Post *)self.model;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelViewController

- (BOOL)shouldLoad
{
	// if we've already displayed and the post does not have a load time
	return _isViewAppearing && !self.post.loadedTime;
}

- (BOOL)shouldReload
{
	return [self shouldLoad];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView
{
	[super loadView];
	self.variableHeightRows = YES;
	[self.view addSubview:self.commentField];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.frame = TTRectContract(self.tableView.frame, 0, self.commentField.frame.size.height);
}

- (void)viewDidUnload {
	TT_RELEASE_SAFELY(_commentField);
	[super viewDidUnload];
}




///////////////////////////////////////////////////////////////////////////////////////////////////
// UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (self.commentField.hasText) {
		[self.post createCommentWithText:self.commentField.text];
		textField.text = @"";
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	// make sure that we haven't hit the max number of chars
	return textField.text.length + (string.length - range.length) < 128;
}
	



///////////////////////////////////////////////////////////////////////////////////////////////////
// keyboard animation listeners

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect r = self.commentField.frame, t;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &t];
    r.origin.y -=  t.size.height;
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    self.commentField.frame = r;
	
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    CGRect r  = self.commentField.frame, t;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &t];
    r.origin.y +=  t.size.height;
	
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    self.commentField.frame = r;
	
    [UIView commitAnimations];
}


////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
	// grab the row's comment
	
	
	// notify the table that the row was selected
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
