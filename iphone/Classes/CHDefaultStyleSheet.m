//
//  CHDefaultStyleSheet.m
//  chiive
//
//  Created by 17FEET on 12/11/09.
//  Copyright 2009 17FEET. All rights reserved.
//

#import "CHDefaultStyleSheet.h"


@implementation CHDefaultStyleSheet

///////////////////////////////////////////////////////////////////////////////////////////////////
// internal

- (UIColor *)buttonColor:(UIColor*)color forState:(UIControlState)state {
	if (state & UIControlStateDisabled) {
		return [color addHue:0 saturation:0 value:-0.5];
		
	} else if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
		return [color addHue:0 saturation:0 value:-0.2];
		
	} else {
		return color;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Colors

- (UIColor*)navigationBarTintColor {
	return RGBCOLOR(0, 0, 0);
}

- (UIColor *)errorColor
{
	return [UIColor redColor];
}

- (UIColor*)roundButtonTopColor {
	//	return RGBCOLOR(154, 227, 75);
	return RGBCOLOR(148, 223, 70);
}

- (UIColor*)roundButtonTopColorDisabled {
	return RGBCOLOR(42, 65, 18);
}

- (UIColor*)roundButtonTopColorForState:(UIControlState)state
{
	if (state & UIControlStateDisabled) {
		return [self roundButtonTopColorDisabled];
		
	} else if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
		return [self buttonColor:[self roundButtonTopColor] forState:state];
		
	} else {
		return [self roundButtonTopColor];
	}
}

- (UIColor*)roundButtonBottomColor {
	//	return RGBCOLOR(70, 153, 5);
	return RGBCOLOR(81, 158, 16);
}

- (UIColor*)roundButtonBottomColorDisabled {
	return RGBCOLOR(76, 110, 43);
}

- (UIColor*)roundButtonBottomColorForState:(UIControlState)state
{
	if (state & UIControlStateDisabled) {
		return [self roundButtonBottomColorDisabled];
		
	} else if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
		return [self buttonColor:[self roundButtonBottomColor] forState:state];
		
	} else {
		return [self roundButtonBottomColor];
	}
}

- (UIColor*)roundCancelButtonTopColor {
	return RGBCOLOR(222, 115, 121);
}

- (UIColor*)roundCancelButtonBottomColor {
	return RGBCOLOR(201, 43, 40);
}

- (UIColor*)discreteButtonTopColor {
	return [UIColor whiteColor];
}

- (UIColor*)discreteButtonBottomColor {
	return [UIColor colorWithWhite:0.91 alpha:1];
}

- (UIColor*)groupStatsButtonDisabledTopColor {
	return [UIColor colorWithWhite:0.22 alpha:1];
}

- (UIColor*)groupStatsButtonDisabledBottomColor {
	return [UIColor blackColor];
}

- (UIColor*)linkTextColor {
	return RGBCOLOR(22,180,254);
}

- (UIColor*)calloutTextColor {
	return RGBCOLOR(105,181,33);
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// override elements

- (UIColor*)tableHeaderTextColor {
	return [UIColor colorWithWhite:0.4 alpha:1]; // RGBCOLOR(74,149,175);
}

- (UIColor*)tableHeaderActiveTextColor {
	return [UIColor whiteColor];
}

- (UIColor*)tableHeaderShadowColor {
	return nil;
}

- (UIColor*)tableHeaderTintColor {
	return [UIColor colorWithWhite:0.93 alpha:1];
}

- (UIFont*)tableHeaderPlainFont {
	return [UIFont boldSystemFontOfSize:14];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// custom elements

- (TTStyle*)tableHeader {
	UIColor* color = TTSTYLEVAR(tableHeaderTintColor);
	UIColor* highlight = [UIColor colorWithWhite:1 alpha:1];
	return
    [TTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, 0, 0, 0) next:
	  [TTFourBorderStyle styleWithTop:nil right:nil bottom:RGBACOLOR(0,0,0,0.15)
								 left:nil width:1 next:nil]]];
}

- (TTStyle*)tableActiveHeader {
	UIColor* color = self.roundButtonTopColor;
	UIColor* highlight = self.roundButtonBottomColor;
	return
    [TTLinearGradientFillStyle styleWithColor1:highlight color2:color next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(-1, 0, 0, 0) next:
	  [TTFourBorderStyle styleWithTop:nil right:nil bottom:RGBACOLOR(0,0,0,0.15)
								 left:nil width:1 next:nil]]];
}

- (TTStyle*)userName {
	return [TTTextStyle styleWithColor:RGBCOLOR(80,109,153) next:nil];
}

- (TTStyle *)h1 {
	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:20] 
								color:self.textColor
						textAlignment:UITextAlignmentCenter next:nil];
}

- (TTStyle *)h2 {
	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:16] 
								color:[UIColor darkGrayColor]
						textAlignment:UITextAlignmentCenter next:nil];
}
- (TTStyle *)h2Inverse {
	return [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:16] 
								color:[UIColor whiteColor]
						textAlignment:UITextAlignmentCenter next:nil];
}
- (TTStyle *)h5 {
	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:14] 
								color:[UIColor darkGrayColor]
						textAlignment:UITextAlignmentCenter next:nil];
}
- (TTStyle *)h5Inverse{
	return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:14] 
								color:[UIColor whiteColor]
						textAlignment:UITextAlignmentCenter next:nil];
}

- (TTStyle *)errorLabel {
	return [TTTextStyle styleWithFont:self.errorSubtitleFont 
								color:self.errorColor
						textAlignment:UITextAlignmentCenter next:nil];
}

- (TTStyle *)statsText {
	return [TTTextStyle styleWithColor:RGBCOLOR(0,154,199) next:nil];
}

- (TTStyle*)groupHeaderLabelBackground {
	return
    [TTLinearGradientFillStyle styleWithColor1:[UIColor colorWithWhite:1 alpha:1] color2:[UIColor colorWithWhite:0.8 alpha:1] next:
	 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(5, 10, 10, 30) next:
	  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:18] color:[UIColor whiteColor] minimumFontSize:0 
					 shadowColor:nil shadowOffset:CGSizeZero
				   textAlignment:UITextAlignmentCenter verticalAlignment:UIControlContentVerticalAlignmentTop 
				   lineBreakMode:UILineBreakModeWordWrap numberOfLines:0 next:nil]]];
}

- (TTStyle*)groupHeaderButtonBackground {
	return [TTLinearGradientFillStyle styleWithColor1:self.roundButtonTopColor
												color2:self.roundButtonBottomColor
												  next:nil];
}

- (TTStyle *)commentBubble {
	return [TTShapeStyle styleWithShape:[TTSpeechBubbleShape shapeWithRadius:2 pointLocation:270
																  pointAngle:270
																   pointSize:CGSizeMake(6,4)] next:
			[TTLinearGradientFillStyle styleWithColor1:[(CHDefaultStyleSheet *)[CHDefaultStyleSheet globalStyleSheet] roundButtonTopColor]
												color2:[(CHDefaultStyleSheet *)[CHDefaultStyleSheet globalStyleSheet] roundButtonBottomColor] 
												  next:
			 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 6, 4, 6) next:
			  [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14] color:[UIColor whiteColor] next:nil]]]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (TTStyle*)toolbarButton:(UIControlState)state {
	TTShape* shape = [TTRoundedRectangleShape shapeWithRadius:4.5];
	UIColor* tintColor = [self roundButtonTopColor];
	return [TTSTYLESHEET toolbarButtonForState:state shape:shape tintColor:tintColor font:nil];
}

- (UIColor*)roundButtonTextColorForState:(UIControlState)state {
	if (state & UIControlStateDisabled) {
		return [UIColor colorWithWhite:1 alpha:0.4];
	} else {
		return [UIColor whiteColor];
	}
}

- (UIColor*)discreteButtonTextColorForState:(UIControlState)state {
	if (state & UIControlStateDisabled) {
		return [UIColor colorWithWhite:0.52 alpha:0.4];
	} else {
		return [UIColor colorWithWhite:0.52 alpha:1];
	}
}

- (UIColor*)groupStatsButtonTextColorForState:(UIControlState)state {
	if (state & UIControlStateDisabled) {
		return [UIColor colorWithWhite:1 alpha:0.75];
	} else {
		return [UIColor colorWithWhite:1 alpha:0.9];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Table refresh header

- (UIFont*)tableRefreshHeaderLastUpdatedFont {
	return [UIFont systemFontOfSize:12.0f];
}

- (UIFont*)tableRefreshHeaderStatusFont {
	return [UIFont boldSystemFontOfSize:13.0f];
}

- (UIColor*)tableRefreshHeaderBackgroundColor {
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_table_header_refresh.png"]];
}

- (UIColor*)tableRefreshHeaderTextColor {
	return [UIColor whiteColor];
}

- (UIColor*)tableRefreshHeaderTextShadowColor {
	return nil;
}

- (CGSize)tableRefreshHeaderTextShadowOffset {
	return CGSizeMake(0.0f, 1.0f);
}

- (UIImage*)tableRefreshHeaderArrowImage {
	return [UIImage imageNamed:@"icon_arrow_table_header_refresh.png"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (TTStyle*)facebookButtonForState:(UIControlState)state shape:(TTShape*)shape {
	UIColor* stateTopColor = [self buttonColor:RGBCOLOR(101,126,175) forState:state];
	UIColor* stateBottomColor = [self buttonColor:RGBCOLOR(66,94,155) forState:state];;
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.06) shadow:RGBACOLOR(0,0,0,0.09)
									   width:4 lightSource:270 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
	    [TTImageStyle styleWithImage:[UIImage imageNamed:@"button_large_facebook_logo.png"] defaultImage:nil 
						 contentMode:UIViewContentModeCenter size:CGSizeZero next:nil
		 ]]]]];
}

- (TTStyle*)largeFacebookButton:(UIControlState)state {
	return [self facebookButtonForState:state
								  shape:[TTRoundedRectangleShape shapeWithRadius:7.5]];
}

- (TTStyle*)largeRoundButtonForState:(UIControlState)state shape:(TTShape*)shape inset:(UIEdgeInsets)insets font:(UIFont*)font {
	UIColor* stateTopColor = [self roundButtonTopColorForState:state];
	UIColor* stateBottomColor = [self roundButtonBottomColorForState:state];;
	UIColor* stateTextColor = [self roundButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.06) shadow:RGBACOLOR(0,0,0,0.09)
									   width:4 lightSource:270 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
		  [TTBoxStyle styleWithPadding:insets next:
		   [TTTextStyle styleWithFont:font
								color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
}

- (TTStyle*)largeRoundCancelButtonForState:(UIControlState)state shape:(TTShape*)shape inset:(UIEdgeInsets)insets font:(UIFont*)font {
	UIColor* stateTopColor = [self roundButtonTopColorForState:state];
	UIColor* stateBottomColor = [self roundButtonBottomColorForState:state];;
	UIColor* stateTextColor = [self roundButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.06) shadow:RGBACOLOR(0,0,0,0.09)
									   width:4 lightSource:270 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
		 [TTBevelBorderStyle styleWithHighlight:nil shadow:RGBACOLOR(0,0,0,0.15)
										  width:1 lightSource:270 next:
		  [TTBoxStyle styleWithPadding:insets next:
		   [TTTextStyle styleWithFont:font
								color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]];
}

- (TTStyle*)homeJoinButtonForState:(UIControlState)state topColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor font:(UIFont*)font {
	UIColor* stateTopColor = [self roundButtonTopColorForState:state];
	UIColor* stateBottomColor = [self roundButtonBottomColorForState:state];;
	UIColor* stateTextColor = [self roundButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:[TTRoundedRectangleShape shapeWithTopLeft:0 topRight:0 bottomRight:7.5 bottomLeft:7.5] next:
	[TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
	 [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 0, 8, 0) next:
	  [TTTextStyle styleWithFont:font
						   color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
					shadowOffset:CGSizeMake(0, -1) next:nil]]]];
}

- (TTStyle*)discreteRoundButtonForState:(UIControlState)state shape:(TTShape*)shape inset:(UIEdgeInsets)insets font:(UIFont*)font {
	UIColor* stateTopColor = [self buttonColor:[self discreteButtonTopColor] forState:state];
	UIColor* stateBottomColor = [self buttonColor:[self discreteButtonBottomColor] forState:state];
	UIColor* stateTextColor = [self discreteButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTSolidBorderStyle styleWithColor:[UIColor colorWithWhite:0.81 alpha:1] width:1 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
		  [TTBoxStyle styleWithPadding:insets next:
		   [TTTextStyle styleWithFont:font color:stateTextColor next:nil]]]]]];
}

- (TTStyle*)largeRoundCancelButton:(UIControlState)state {
	return [self largeRoundCancelButtonForState:state
									shape:[TTRoundedRectangleShape shapeWithRadius:10.5]
									inset:UIEdgeInsetsMake(14, 20, 14, 20)
									 font:[UIFont boldSystemFontOfSize:18]];
}
- (TTStyle*)largeRoundButton:(UIControlState)state {
	return [self largeRoundButtonForState:state
									shape:[TTRoundedRectangleShape shapeWithRadius:10.5]
									inset:UIEdgeInsetsMake(14, 20, 14, 20)
									 font:[UIFont boldSystemFontOfSize:18]];
}
- (TTStyle*)homeJoinButton:(UIControlState)state {
	return [self homeJoinButtonForState:state topColor:self.roundButtonTopColor bottomColor:self.roundButtonBottomColor 
								   font:[UIFont boldSystemFontOfSize:17]];
}
- (TTStyle*)homeViewButton:(UIControlState)state {
	return [self homeJoinButtonForState:state topColor:[UIColor colorWithWhite:0.22 alpha:1] 
							bottomColor:[UIColor blackColor] 
								   font:[UIFont boldSystemFontOfSize:17]];
}
- (TTStyle*)smallRoundButton:(UIControlState)state {
	return [self largeRoundButtonForState:state
									shape:[TTRoundedRectangleShape shapeWithRadius:8.5]
									inset:UIEdgeInsetsMake(8, 12, 8, 12)
									 font:[UIFont boldSystemFontOfSize:14]];
}
- (TTStyle*)discreteRoundButton:(UIControlState)state {
	return [self discreteRoundButtonForState:state
									shape:[TTRoundedRectangleShape shapeWithRadius:8.5]
									inset:UIEdgeInsetsMake(6, 8, 6, 8)
									 font:[UIFont boldSystemFontOfSize:13]];
}
- (TTStyle*)groupStatsButtonForState:(UIControlState)state shape:(TTShape*)shape font:(UIFont*)font {
	UIColor* stateTopColor = [self roundButtonTopColorForState:state];
	UIColor* stateBottomColor = [self roundButtonBottomColorForState:state];;
	UIColor* stateTextColor = [self groupStatsButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.06) shadow:RGBACOLOR(0,0,0,0.09)
									   width:4 lightSource:270 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
		   [TTTextStyle styleWithFont:font 
								color:stateTextColor 
					  minimumFontSize:11 
						  shadowColor:[UIColor colorWithWhite:0 alpha:0.4] shadowOffset:CGSizeMake(0, -1)  
						textAlignment:UITextAlignmentCenter verticalAlignment:UIControlContentVerticalAlignmentCenter 
						lineBreakMode:UILineBreakModeTailTruncation numberOfLines:1 
								 next:nil]]]]]];
}

- (TTStyle*)groupStatsButton:(UIControlState)state {
	return [self groupStatsButtonForState:state
									shape:[TTRoundedRectangleShape shapeWithRadius:7.5]
									 font:[UIFont boldSystemFontOfSize:18]];
}

- (TTStyle*)roundButtonForState:(UIControlState)state shape:(TTShape*)shape font:(UIFont*)font {
	UIColor* stateTopColor = [self buttonColor:[self roundButtonTopColor] forState:state];
	UIColor* stateBottomColor = [self buttonColor:[self roundButtonBottomColor] forState:state];;
	UIColor* stateTextColor = [self roundButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.06) shadow:RGBACOLOR(0,0,0,0.09)
									   width:1 lightSource:270 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
		  [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8,10,8,10) next:
		   [TTTextStyle styleWithFont:font
								color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
}

- (TTStyle*)roundButton:(UIControlState)state {
	return [self roundButtonForState:state
							   shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
								font:nil];
}

- (TTStyle*)roundCancelButtonForState:(UIControlState)state shape:(TTShape*)shape font:(UIFont*)font {
	UIColor* stateTopColor = [self buttonColor:[self roundCancelButtonTopColor] forState:state];
	UIColor* stateBottomColor = [self buttonColor:[self roundCancelButtonBottomColor] forState:state];;
	UIColor* stateTextColor = [self roundButtonTextColorForState:state];
	
	return 
    [TTShapeStyle styleWithShape:shape next:
	 [TTInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
	  [TTBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.06) shadow:RGBACOLOR(0,0,0,0.09)
									   width:1 lightSource:270 next:
	   [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
		[TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
		  [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(8,10,8,10) next:
		   [TTTextStyle styleWithFont:font
								color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
						 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
}

- (TTStyle*)roundCancelButton:(UIControlState)state {
	return [self roundCancelButtonForState:state
							   shape:[TTRoundedRectangleShape shapeWithRadius:4.5]
								font:nil];
}

- (TTStyle*)refreshButton:(UIControlState)state {
	UIColor* stateTopColor = [UIColor whiteColor];
	UIColor* stateBottomColor = RGBCOLOR(225,225,225);
	UIColor* stateTextColor = [UIColor darkGrayColor];
	
	if (state & UIControlStateDisabled) {
		stateBottomColor = RGBCOLOR(240,240,240);
		stateTextColor = [UIColor lightGrayColor];
		
	} else if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
		stateBottomColor = RGBCOLOR(200,200,200);
	}
	
	UIFont*	font = [UIFont boldSystemFontOfSize:17];
	
	return 
	[TTInsetStyle styleWithInset:UIEdgeInsetsMake(0, 0, 4, 0) next:
	 [TTLinearGradientFillStyle styleWithColor1:stateTopColor color2:stateBottomColor next:
	  [TTBoxStyle styleWithPadding:UIEdgeInsetsMake(-10,0,0,0) next:
	   [TTTextStyle styleWithFont:font
							color:stateTextColor shadowColor:[UIColor colorWithWhite:1 alpha:0.4]
					 shadowOffset:CGSizeMake(0, -1) next:nil]]]];
}

@end
