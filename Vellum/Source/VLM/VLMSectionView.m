//
//  VLMSectionView.m
//  Vellum
//
//  Created by David Lu on 6/21/13.
//
//

#import "VLMSectionView.h"


@implementation VLMSectionView
@synthesize headerLabel;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		[headerLabel setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
		[headerLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
		[headerLabel setFrame:CGRectMake(0, 0, 320, 60)];
		[headerLabel setTextColor:[UIColor whiteColor]];
		[headerLabel setNumberOfLines:2];
		[headerLabel setTextAlignment:NSTextAlignmentCenter];
		[headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		[self addSubview:headerLabel];
		[self setBackgroundColor:[UIColor clearColor]];
		[self setUserInteractionEnabled:NO];
	}
	return self;
}

- (void)setText:(NSString *)text {
	[self.headerLabel setText:text];
}

- (void)setAttributedText:(NSMutableAttributedString *)text {
	[self.headerLabel setAttributedText:text];
}

- (void)reset {
	[self.headerLabel setText:@""];
}

+ (CGFloat)expectedViewHeightForText:(NSString *)text {
	return 60.0f;
	/*
     CGSize expectedLabelSize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f] constrainedToSize:CGSizeMake(270, 120) lineBreakMode:UILineBreakModeWordWrap];
     CGFloat h = expectedLabelSize.height + 14.0f * 2.0f;
     
     h = ceilf( h / 14.0f ) * 14.0f;
     return h;
	 */
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
