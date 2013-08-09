//
//  VLMAboutButton.m
//  Vellum
//
//  Created by David Lu on 8/9/13.
//
//

#import "VLMAboutButton.h"
#import "VLMConstants.h"

@interface VLMAboutButton()
@property (nonatomic, strong) UIView *shade;
@end

@implementation VLMAboutButton
@synthesize shade;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setAdjustsImageWhenHighlighted:NO];
		[self setShade:[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
		[self.shade setUserInteractionEnabled:NO];
		[self.shade setBackgroundColor:[UIColor blackColor]];
		[self.shade setAlpha:0.0f];
		[self addSubview:self.shade];
    }
    return self;
}

// from http://stackoverflow.com/questions/15237956/how-to-animate-transition-from-one-state-to-another-for-uicontrol-uibutton
- (void)setHighlighted:(BOOL)highlighted {
	// Check if button is going from not highlighted to highlighted
	if (![self isHighlighted] && highlighted) {
		[self.shade setAlpha:0.5f];
	}
	// Check if button is going from highlighted to not highlighted
	else if ([self isHighlighted] && !highlighted) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0.0f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:ANIMATION_DURATION];
		[self.shade setAlpha:0.0f];
		[UIView commitAnimations];
	}
    
	[super setHighlighted:highlighted];
}

@end
