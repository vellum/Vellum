//
//  VLMZoomViewController.m
//  Test
//
//  Created by David Lu on 4/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMZoomViewController.h"

@interface VLMZoomViewController ()

@end

@implementation VLMZoomViewController

@synthesize label;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setAlpha:0];
	
    // Do any additional setup after loading the view.
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [self.view setFrame:bounds];
    
    CGFloat diameter = 106;
    CGRect rect = CGRectMake(bounds.size.width/2-diameter/2, diameter, diameter, diameter);
    
    UIView *circle = [[UIView alloc] initWithFrame:rect];
    
    [circle setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.75]];
    [circle setFrame:rect];
    [circle.layer setCornerRadius:diameter/2];
    [self.view addSubview:circle];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:rect];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont boldSystemFontOfSize:diameter*0.35]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setText:@"0%"];
    [lbl setAdjustsFontSizeToFitWidth:YES];
    self.label = lbl;
    [self.view addSubview:lbl];
    [self.view setUserInteractionEnabled:NO];
}

-(void)show
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	[self.view setAlpha:1.0];
	[UIView commitAnimations];
}

-(void)hide
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
	[self.view setAlpha:0.0];
	[UIView commitAnimations];
}

- (void)setText:(int)value{
    NSString *t = [NSString stringWithFormat:@"%i%%",value];
    NSLog(@"%@", t );
	[label setText:t];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
