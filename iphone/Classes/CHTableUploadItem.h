//
//  CHTableUploadItemCell.h
//  chiive
//
//  Created by Arrel Gray on 12/29/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHTableItem.h"

@class RESTObject;

@interface CHTableUploadItem : TTTableSubtitleItem {
	RESTObject *_model;
}
@property (nonatomic, retain) RESTObject	*model;
@end

@interface CHTableUploadItemCell : TTTableSubtitleItemCell <TTModelDelegate, TTURLRequestDelegate> {
	UISlider			*_progressView;
	UIImageView			*_progressBackgroundView;
	UIButton			*_cancelButton;
	RESTObject			*_model;
}
@property (nonatomic, retain)	RESTObject			*model;
@property (nonatomic, readonly) UISlider			*progressView;
@property (nonatomic, readonly) UIButton			*cancelButton;

@end
