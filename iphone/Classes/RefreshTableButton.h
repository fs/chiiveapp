//
//  RefreshTableButton.h
//  chiive
//
//  Created by 17FEET on 9/25/09.
//  Copyright 2009 17FEET. All rights reserved.
//



@interface RefreshTableButton : TTButton <TTModelDelegate> {
	TTModel		*_model;
	UIImageView	*_icon;
}

@property (nonatomic, retain) TTModel	*model;

@end
