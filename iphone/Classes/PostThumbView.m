//
//  PostTableItemThumbView.m
//  chiive
//
//  Created by Arrel Gray on 11/26/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "PostThumbView.h"
#import "Post.h"

static CGFloat kImageBorder = 4;

@implementation PostThumbView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		// create the image background
		_backgroundView = [[TTView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		_backgroundView.backgroundColor = [UIColor whiteColor];
		_backgroundView.style = [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithRadius:3] next:
								 [TTSolidFillStyle styleWithColor:[UIColor whiteColor] next:
								  [TTSolidBorderStyle styleWithColor:RGBCOLOR(220, 220, 220) width:1 next:nil]]];
		[self addSubview:_backgroundView];
		
		// create the image view
		_imageView = [[TTImageView alloc] initWithFrame:CGRectMake(kImageBorder, kImageBorder, frame.size.width - kImageBorder * 2, frame.size.height - kImageBorder * 2)];
		_imageView.defaultImage = [UIImage imageNamed:@"list_loading.png"];
		[self addSubview:_imageView];
	}
	return self;
}

/**
 * When the post is assigned, assign the url to the image object.
 */
- (void)setPost:(Post *)post {
	if (post != _post)
	{
		[post retain];
		[_post release];
		_post = post;
		_imageView.urlPath = [_post URLForVersion:TTPhotoVersionThumbnail];
	}
}
- (Post *)post
{
	return _post;
}

/**
 * On click the photo, pass along to the controller.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self.delegate postThumbView:self didSelectPost:self.post];
	[super touchesEnded:touches withEvent:event];
}

@end
