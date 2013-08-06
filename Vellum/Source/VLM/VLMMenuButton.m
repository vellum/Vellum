//
//  VLMMenuButton.m
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import "VLMMenuButton.h"
#import "VLMConstants.h"

@interface VLMMenuButton ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *shade;
@end

@implementation VLMMenuButton
@synthesize label;
@synthesize shade;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
		[self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
		[self.label setTextAlignment:NSTextAlignmentCenter];
		[self.label setTextColor:[UIColor blackColor]];
		[self.label setBackgroundColor:[UIColor clearColor]];
		[self.label setNumberOfLines:2];
		[self addSubview:self.label];
		[self setBackgroundImage:[UIImage imageNamed:@"menu_default.png"] forState:UIControlStateNormal];
		[self setBackgroundImage:[UIImage imageNamed:@"menu_selected.png"] forState:UIControlStateSelected];
		[self setAdjustsImageWhenHighlighted:NO];
        
		[self setShade:[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
		[self.shade setUserInteractionEnabled:NO];
		[self.shade setBackgroundColor:[UIColor blackColor]];
		[self.shade setAlpha:0.0f];
		[self addSubview:self.shade];
	}
	return self;
}

- (void)setText:(NSString *)text {
    NSString *formatted = [text stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
	[self.label setText:formatted];
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
