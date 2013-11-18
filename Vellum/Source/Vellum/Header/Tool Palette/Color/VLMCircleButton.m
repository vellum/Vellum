//
//  VLMCircleButton.m
//  Vellum
//
//  Created by David Lu on 7/29/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "VLMCircleButton.h"
#import "VLMConstants.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface VLMCircleButton ()
@property CGRect originalRect;
@property (nonatomic, strong) UIView *shade;
@property (nonatomic, strong) UIView *colorfield;
@property (nonatomic, strong) UIView *borderfield;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *back;
@end

@implementation VLMCircleButton
@synthesize originalRect;
@synthesize shade;
@synthesize colorfield;
@synthesize borderfield;
@synthesize label;
@synthesize back;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
        
		//[self.layer setCornerRadius:frame.size.width/2.0f];
		[self setAutoresizesSubviews:NO];
		[self setClipsToBounds:YES];
		[self setOriginalRect:frame];
		[self setAdjustsImageWhenHighlighted:NO];
        
		[self setBack:[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
		[self.back setAutoresizesSubviews:NO];
		[self.back setUserInteractionEnabled:NO];
		[self.back setBackgroundColor:[UIColor clearColor]];
		[self addSubview:back];
        
        [self setBorderfield:[[UIView alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 60.0f) / 2.0f), floorf((frame.size.height - 60.0f) / 2.0f), 60.0f, 60.0f)]];
		[self.borderfield setUserInteractionEnabled:NO];
		[self.borderfield.layer setCornerRadius:30.0f];
		[self.borderfield setBackgroundColor:[UIColor clearColor]];
        [self.borderfield setAlpha:0.5f];
		[self.back addSubview:self.borderfield];

		[self setColorfield:[[UIView alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 50.0f) / 2.0f), floorf((frame.size.height - 50.0f) / 2.0f), 50.0f, 50.0f)]];
		[self.colorfield setUserInteractionEnabled:NO];
		[self.colorfield.layer setCornerRadius:25.0f];
		[self.back addSubview:self.colorfield];


		[self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
		[self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
		[self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];

		[self.label setBackgroundColor:[UIColor clearColor]];
		[self.label setNumberOfLines:2];
		[self.label setUserInteractionEnabled:NO];
		[self.back addSubview:self.label];
        
        
        
		[self setShade:[[UIView alloc] initWithFrame:CGRectMake(floorf((frame.size.width - 60.0f) / 2.0f), floorf((frame.size.height - 60.0f) / 2.0f), 60.0f, 60.0f)]];
		[self.shade setUserInteractionEnabled:NO];
		[self.shade.layer setCornerRadius:30.0f];
		[self.shade setBackgroundColor:[UIColor blackColor]];
		[self.shade setAlpha:0.0f];
		[self addSubview:self.shade];
        
		[self hide];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (void)show {
	[self showWithDelay:self.tag * 0.1f];
}

- (void)hide {
	[self hideWithDelay:(self.tag) * 0.1f];
}

- (void)showWithDelay:(CGFloat)delay {
	[self.layer setCornerRadius:self.frame.size.width / 2.0f];
	[UIView animateWithDuration:ANIMATION_DURATION * 2
	                      delay:delay
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [self setFrame:self.originalRect];
                     }
     
	                 completion: ^(BOOL finished) {
                         [self.layer setCornerRadius:0.0f];
                     }
     
     ];
}

- (void)hideWithDelay:(CGFloat)delay {
	[self.layer setCornerRadius:self.frame.size.width / 2.0f];
	[UIView animateWithDuration:ANIMATION_DURATION
	                      delay:delay
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [self setFrame:CGRectMake(originalRect.origin.x + originalRect.size.width / 2.0f, originalRect.size.height / 2.0f, 0.0f, 0.0f)];
                     }
     
	                 completion: ^(BOOL finished) {
                         [self.layer setCornerRadius:0.0f];
                     }
     
     ];
}

- (void)setHighlighted:(BOOL)highlighted {
	//NSLog(@"sethighlighted");
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

- (void)setText:(NSString *)text {
	NSUInteger location = [text rangeOfString:@"\n" options:NSCaseInsensitiveSearch].location;
	if (location != NSNotFound) {
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:text];
        [att setAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:9.0f] } range:NSMakeRange(0, location)];
        [self.label setAttributedText:att];
        return;
	}
	[self.label setText:text];
}

- (void)setSelected:(BOOL)selected {
	if (selected) {
        [self.borderfield setBackgroundColor:[UIColor whiteColor]];
        [self.borderfield setAlpha:1.0f];
	}
	else {
        [self.borderfield setBackgroundColor:[UIColor blackColor]];
        [self.borderfield setAlpha:0.1f];
	}
	[super setSelected:selected];
}

- (void)setHue:(CGFloat)h Saturation:(CGFloat)s Brightness:(CGFloat)b Alpha:(CGFloat)a {
    [self.colorfield setBackgroundColor:[UIColor colorWithHue:h saturation:s brightness:b alpha:a]];
}

- (void)setColor:(UIColor *)color{
    [self.colorfield setBackgroundColor:color];
}

- (void)setTextColor:(UIColor *)color{
    [self.label setTextColor:color];
}
    
- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    //[self.colorfield setAlpha:enabled?1.0f:0.25f];
    //[self.label setAlpha:enabled?1.0f:0.25f];
}
@end
