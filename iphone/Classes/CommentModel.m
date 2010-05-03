//
//  CommentModel.m
//  chiive
//
//  Created by 17FEET on 12/3/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CommentModel.h"
#import "Comment.h"
#import "RESTObject.h"
#import "Global.h"
#import "RESTModelComplete.h"
#import "Post.h"

@implementation CommentModel
@synthesize post = _post;


///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setPost:(Post *)post
{
	if (post != _post)
	{
		if (!!_post)
			[self removeChildren];
		
		[post retain];
		[_post release];
		_post = post;
		
		[self beginUpdates];
		[self insertChildren:[_post.comments allObjects]];
		[self.children sortUsingDescriptors:self.sortDescriptors];
		[self endUpdates];
		[self didFinishLoad];
		
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// RESTModel

- (Class)childClass
{
	return [Comment class];
}

- (NSString *)childName
{
	return @"comment";
}

- (NSString *)childrenName
{
	return @"comments";
}

- (NSString *)childrenURL
{
	return [NSString stringWithFormat:@"/%@.json",
			self.post.URL,
			self.childrenName
			];
}

- (BOOL)insertChild:(RESTObject *)child atIndex:(NSInteger)index
{
	Comment *comment = (Comment *)child;
	comment.post = self.post;
	return [super insertChild:child atIndex:index];
}

- (NSArray *)sortDescriptors
{
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO] autorelease];
	return [NSArray arrayWithObject:sortDescriptor];
}

- (BOOL)destroyChildrenOnRemove
{
	// only delete when we're in the midst of an update
	return self.isUpdating;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_post);
	[super dealloc];
}

@end
