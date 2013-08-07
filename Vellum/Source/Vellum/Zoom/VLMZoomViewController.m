//
//  VLMZoomViewController.m
//  Test
//
//  Created by David Lu on 4/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMZoomViewController.h"
#import "VLMConstants.h"

@interface VLMZoomViewController ()

@end

@implementation VLMZoomViewController

@synthesize label;
@synthesize zoomlevel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	CGRect bounds = [[UIScreen mainScreen] bounds];
	CGFloat diameter = 106;
	CGRect rect = CGRectMake(bounds.size.width / 2 - diameter / 2, diameter, diameter, diameter);
	UIView *circle = [[UIView alloc] initWithFrame:rect];
	UILabel *lbl = [[UILabel alloc] initWithFrame:rect];
    
	[self setZoomlevel:1];
	[self.view setAlpha:0];
	[self.view setUserInteractionEnabled:NO];
	[self.view setFrame:bounds];
    
	[circle setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.75]];
	[circle setFrame:rect];
	[circle.layer setCornerRadius:diameter / 2];
	[self.view addSubview:circle];
    
	[lbl setTextAlignment:NSTextAlignmentCenter];
	[lbl setFont:[UIFont boldSystemFontOfSize:diameter * 0.35]];
	[lbl setBackgroundColor:[UIColor clearColor]];
	[lbl setTextColor:[UIColor whiteColor]];
	[lbl setText:@"0%"];
	[lbl setAdjustsFontSizeToFitWidth:YES];
	[self.view addSubview:lbl];
	[self setLabel:lbl];
    
	[self.view.layer setZPosition:1000.0f];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - ()

- (void)show {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:ANIMATION_DURATION];
	[self.view setAlpha:1.0];
	[UIView commitAnimations];
}

- (void)hide {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:ANIMATION_DURATION * 2];
	[self.view setAlpha:0.0];
	[UIView commitAnimations];
}

- (void)setText:(int)value {
	NSString *t = [NSString stringWithFormat:@"%i%%", value];
	self.zoomlevel = (CGFloat)value / 100.0f;
	[label setText:t];
}

- (BOOL)isVisible {
	return (self.view.alpha == 1.0f);
}

@end
