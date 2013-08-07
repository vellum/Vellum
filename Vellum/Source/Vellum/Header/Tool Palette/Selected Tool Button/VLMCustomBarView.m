//
//  VLMCustomBarView.m
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import "VLMCustomBarView.h"

@implementation VLMCustomBarView
@synthesize yoffset;
- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
		yoffset = 2.0f; //-2.0f;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	return;
	/*
     
     CGFloat w = 18.0f;
     CGFloat h = w;
     CGFloat x = roundf(midx - w/2.0f);
     CGFloat y = roundf(midy - h/2.0f) + yoffset;
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     //CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.25f].CGColor);
     //CGContextFillEllipseInRect(context, CGRectMake(x, y, w, h));
     
     //CGContextAddEllipseInRect(context, CGRectMake(x, y, w, h));
     //CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.25f].CGColor);
     //CGContextSetLineWidth(context, 1.0f);
     //CGContextStrokePath(context);
     
     w = 10.0f;
     h = w;
     x = roundf(midx - w/2.0f);
     y = roundf(midy - h/2.0f) + yoffset;
     //CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.5f].CGColor);
     //CGContextFillEllipseInRect(context, CGRectMake(x, y, w, h));
     CGContextAddEllipseInRect(context, CGRectMake(x, y, w, h));
     CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor);
     CGContextSetLineWidth(context, 1.0f);
     
     CGContextStrokePath(context);
     
     //*/
	///*
	CGFloat midy = roundf(rect.size.height / 2.0f);
	CGFloat midx = roundf(rect.size.width / 2.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat w = 4.0f;
	CGFloat h = 4.0f;
	CGFloat m = 0.0f;
	int numNotches = 10;
	CGFloat totalw = numNotches * w + (numNotches - 1) * (m);
	CGFloat x = roundf(midx - totalw / 2);
	CGFloat y = roundf(midy - h / 2.0f) + yoffset;
	for (int i = 0; i < numNotches; i++) {
		if (i < 0.5f * numNotches) {
			CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:1.0f].CGColor);
		}
		else {
			CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.25f].CGColor);
		}
		CGContextFillRect(context, CGRectMake(x, y, w, h));
		x += (w + m);
	}
	//*/
}

@end
