//
//  VLMCustomXView.m
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import "VLMCustomXView.h"

@implementation VLMCustomXView
@synthesize yoffset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        yoffset = 0.0f;//-2.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat midy = roundf(rect.size.height / 2.0f);
    CGFloat midx = roundf(rect.size.width / 2.0f);
    
    CGFloat w = 12.0f;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0f alpha:0.75f].CGColor);
    CGContextSetLineWidth(context, 1.5f);
    
    CGContextMoveToPoint(context, roundf(midx-w/2.0f), roundf(midy - w/2.0f + yoffset));
    CGContextAddLineToPoint(context, roundf(midx+w/2.0f), roundf(midy+w/2.0f + yoffset));
    CGContextMoveToPoint(context, roundf(midx-w/2.0f), roundf(midy + w/2.0f + yoffset));
    CGContextAddLineToPoint(context, roundf(midx+w/2.0f), roundf(midy-w/2.0f + yoffset));
    CGContextStrokePath(context);
    
}

@end
