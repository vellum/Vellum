//
//  VLMScrollView.m
//  Vellum
//
//  Created by David Lu on 6/19/13.
//
//

#import "VLMScrollView.h"

@implementation VLMScrollView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
	}
	return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
	if ([view isKindOfClass:[UIButton class]]) return YES;
	return NO;
}

@end
