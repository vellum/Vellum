//
//  VLMArcView.m
//  Vellum
//
//  Created by David Lu on 5/11/13.
//
//

#import "VLMArcView.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

@implementation VLMArcView
@synthesize index;
@synthesize shapeCount;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setIndex:0];
        [self setShapeCount:10];
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
    
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGContextBeginPath(ctx);
    CGFloat radius = rect.size.width / 2;
    for (CGFloat i = 0; i <= self.shapeCount; i++) {
        CGFloat radians = i / (CGFloat)self.shapeCount *  M_PI * 2.0f - M_PI/2.0f;
        CGFloat x = center.x + cos(radians) * radius;
        CGFloat y = center.y + sin(radians) * radius;
        if (i == 0) CGContextMoveToPoint(ctx, x, y);
        else CGContextAddLineToPoint(ctx, x, y);
    }
    CGContextAddLineToPoint(ctx, center.x, center.y);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    
    CGContextSetRGBFillColor(ctx, 0.9, 0.9, 0.9, 1);
    CGContextBeginPath(ctx);
    for (CGFloat i = 0; i <= self.index; i++) {
        CGFloat radians = i / (CGFloat)self.shapeCount *  M_PI * 2.0f - M_PI / 2.0f;
        CGFloat x = center.x + cos(radians) * radius;
        CGFloat y = center.y + sin(radians) * radius;
        if (i == 0) CGContextMoveToPoint(ctx, x, y);
        else CGContextAddLineToPoint(ctx, x, y);
    }
    CGContextAddLineToPoint(ctx, center.x, center.y);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

@end
