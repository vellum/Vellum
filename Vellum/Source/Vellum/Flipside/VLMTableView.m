//
//  VLMTableView.m
//  Vellum
//
//  Created by David Lu on 7/12/13.
//
//

#import "VLMTableView.h"

@implementation VLMTableView

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
