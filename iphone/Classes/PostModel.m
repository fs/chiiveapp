//
//  PostModel.m
//  chiive
//
//  Created by 17FEET on 10/21/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "PostModel.h"
#import "Global.h";
#import "Post.h";
#import "UploadQueue.h";
#import "Group.h"

@implementation PostModel
@synthesize group = _group, filterByUser = _filterByUser;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setGroup:(Group *)group
{
	if (group != _group)
	{
		[self removeChildren];
		
		[group retain];
		[_group release];
		_group = group;
		
		[self beginUpdates];
		[self insertChildren:[_group.posts allObjects]];
		[self.children sortUsingDescriptors:self.sortDescriptors];
		[self endUpdates];
		[self didFinishLoad];
	}
}


- (void)setFilterByUser:(User *)filterByUser
{
	if (filterByUser != _filterByUser)
	{
		if (!_filteredChildren)
			_filteredChildren = [[NSMutableArray array] retain];
		else
			[_filteredChildren removeAllObjects];
			
		[filterByUser retain];
		[_filterByUser release];
		_filterByUser = filterByUser;
		
		if (!!_filterByUser)
		{
			for (Post *post in self.children) {
				if (post.user == _filterByUser)
					[_filteredChildren addObject:post];
			}
		}
	}
}

/**
 * Support function for finding the index of children in relation to one another.
 * Used for returning values to TTPhotoSource.
 */
- (NSUInteger)indexOfChild:(RESTObject *)child
{
	if (!_filterByUser)
		return [self.children indexOfObject:child];
	else
		return [_filteredChildren indexOfObject:child];
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSString *)title
{
	return self.group.prettyTitle;
}

- (void)setTitle:(NSString *)title
{
	self.group.title = title;
}

/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
-(NSInteger)numberOfPhotos
{
	if (!!_filterByUser)
		return [_filteredChildren count];
	else
		return self.numberOfChildren;
}

/**
 * The maximum index of photos that have already been loaded.
 */
-(NSInteger)maxPhotoIndex
{
	if (!!_filterByUser)
		return [_filteredChildren count] - 1;
	else
		return self.numberOfChildrenLoaded - 1;
}

/**
 * Return the Post object at the given index, or nil if out of range.
 */
- (id<TTPhoto>)photoAtIndex:(NSInteger)index
{
	if (index < 0)
		index = 0;
	
	NSArray *arrayToUse = !_filterByUser ? self.children : _filteredChildren;
	return index <= self.maxPhotoIndex ? [arrayToUse objectAtIndex:index] : nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESTModel

- (NSUInteger)numberOfChildren
{
	return self.group.numPosts;
}

- (Class)childClass
{
	return [Post class];
}

- (NSString *)childrenURL
{
	return [NSString stringWithFormat:@"%@events/%@/%@.json",
			[Global getInstance].sitePath,
			self.group.UUID,
			self.childrenName
			];
}

- (BOOL)insertChild:(RESTObject *)child atIndex:(NSInteger)index
{
	Post *post = (Post *)child;
	post.group = self.group;
	return [super insertChild:child atIndex:index];
}

- (void)updateChild:(RESTObject *)child withProperties:properties
{
	[super updateChild:child withProperties:properties];
	Post *post = (Post *)child;
	
	if (post.group != self.group)
	{
		[[post.group postModel] removeChild:post];
		post.group = self.group;
	}
		
	if (!post.user || [Global getInstance].currentUser == post.user)
	{
		post.user = [Global getInstance].currentUser;
	}
}

/**
 * Only destroy while making an update, so that "deleted" posts
 * can run a remote delete request on the server, then destroy themselves upon response.
 */
- (BOOL)destroyChildrenOnRemove
{
	return self.isUpdating;
}

- (NSArray *)sortDescriptors
{
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"captured_at" ascending:NO] autorelease];
	return [NSArray arrayWithObject:sortDescriptor];
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(_group);
	TT_RELEASE_SAFELY(_filterByUser);
	[super dealloc];
}

@end
