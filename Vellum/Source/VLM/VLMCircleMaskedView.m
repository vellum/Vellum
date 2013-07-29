//
//  VLMCircleMaskedView.m
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import "VLMCircleMaskedView.h"
#import <QuartzCore/QuartzCore.h>
#import "VLMConstants.h"

@interface VLMCircleMaskedView()
@property CGRect originalRect;
@end

@implementation VLMCircleMaskedView
@synthesize originalRect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setCornerRadius:frame.size.width/2.0f];
        [self setAutoresizesSubviews:NO];
        [self setClipsToBounds:YES];
        [self setOriginalRect:frame];
    
        [self setFrame:CGRectMake(originalRect.origin.x + originalRect.size.width/2.0f, originalRect.size.height/2.0f, 0.0f, 0.0f)];
        
        CGFloat m = (frame.size.width - 60.0f)/2.0f;
        UIView *outie = [[UIView alloc] initWithFrame:CGRectMake(m, m, 60.0f, 60.0f)];
        [outie.layer setCornerRadius:30.0f];
        [outie setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
        [self addSubview:outie];
        
        UIView *innie = [[UIView alloc] initWithFrame:CGRectMake(m+5, m+5, 50.0f, 50.0f)];
        [innie.layer setCornerRadius:25.0f];
        [innie setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:innie];
        
    }
    return self;
}

- (void)show{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay: self.tag *0.1f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self setFrame:self.originalRect];
    [UIView commitAnimations];
}

- (void)hide{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay: (self.tag) *0.1f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self setFrame:CGRectMake(originalRect.origin.x + originalRect.size.width/2.0f, originalRect.size.height/2.0f, 0.0f, 0.0f)];
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



@end
