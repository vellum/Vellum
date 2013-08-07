//
//  VLMTriangleView.m
//  Ejecta
//
//  Created by David Lu on 5/5/13.
//
//

#import "VLMTriangleView.h"

@implementation VLMTriangleView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self setBackgroundColor:[UIColor clearColor]];
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
- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextClearRect(ctx, rect);
	CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    
	CGPoint topcenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint leftbottom = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
	CGPoint rightbottom = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, topcenter.x, topcenter.y);
	CGContextAddLineToPoint(ctx, leftbottom.x, leftbottom.y);
	CGContextAddLineToPoint(ctx, rightbottom.x, rightbottom.y);
	CGContextClosePath(ctx);
	CGContextFillPath(ctx);
}

@end
