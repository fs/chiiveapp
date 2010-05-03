//
//  CHDefaultStyleSheet.h
//  chiive
//
//  Created by 17FEET on 12/11/09.
//  Copyright 2009 17FEET. All rights reserved.
//


@interface CHDefaultStyleSheet : TTDefaultStyleSheet

@property (nonatomic, readonly) TTStyle *tableActiveHeader;
@property (nonatomic, readonly) TTStyle *h2;
@property (nonatomic, readonly) TTStyle *h2Inverse;
@property (nonatomic, readonly) TTStyle *h5;
@property (nonatomic, readonly) TTStyle *h5Inverse;
@property (nonatomic, readonly) TTStyle	*statsText;
@property (nonatomic, readonly) UIColor *tableHeaderActiveTextColor;
@property (nonatomic, readonly) UIColor	*errorColor;
@property (nonatomic, readonly) UIColor	*roundButtonTopColor;
@property (nonatomic, readonly) UIColor	*roundButtonBottomColor;
@property (nonatomic, readonly) UIColor	*calloutTextColor;

@end
