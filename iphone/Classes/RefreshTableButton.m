//
//  RefreshTableButton.m
//  chiive
//
//  Created by 17FEET on 9/25/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "RefreshTableButton.h"


@implementation RefreshTableButton

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)init {
	if (self = [super init]) {
		[self setTitle:@"    Refresh" forState:UIControlStateNormal];
		[self setStylesWithSelector:@"refreshButton:"];
		
		_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_table_header_refresh.png"]];
		_icon.frame = CGRectOffset(_icon.frame, 110, 3);
		[self addSubview:_icon];
	}
	return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModelDelegate

- (TTModel *)model {
	return _model;
}

- (void)setModel:(TTModel *)model {
	if (model != _model) {
		[[_model delegates] removeObject:self];
		[model retain];
		[_model release];
		_model = model;
		[[_model delegates] addObject:self];
	}
}

- (void)modelDidStartLoad:(id<TTModel>)model {
	_icon.hidden = YES;
	[self setTitle:@"Reloading..." forState:UIControlStateNormal];
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
	_icon.hidden = NO;
	[self setTitle:@"    Refresh" forState:UIControlStateNormal];
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
	_icon.hidden = YES;
	[self setTitle:@"Connection error!" forState:UIControlStateNormal];
}

- (void)modelDidCancelLoad:(id<TTModel>)model {
	_icon.hidden = YES;
	[self setTitle:@"Reload Canceled" forState:UIControlStateNormal];
}

- (void)dealloc {
	self.model = nil;
	[_model release];
	TT_RELEASE_SAFELY(_icon);
	[super dealloc];
}

@end
