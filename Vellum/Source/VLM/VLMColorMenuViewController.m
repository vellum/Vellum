//
//  VLMColorMenuViewController.m
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import "VLMColorMenuViewController.h"
#import "VLMConstants.h"

@interface VLMColorMenuViewController ()

@end

@implementation VLMColorMenuViewController

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

    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;

    CGFloat margin = 0.0f;
    CGFloat innermargin = 3.0f;
    CGFloat pad = 1;
    CGFloat buttonsize = 75.0f;
    
    CGPoint topleft;
    topleft = CGPointMake(innermargin, innermargin);
        
    [self.view setFrame:CGRectMake(0.0f, HEADER_HEIGHT + buttonsize + 2*innermargin, winw, buttonsize + margin*2 + innermargin*2)];
    [self.view setBackgroundColor:[UIColor redColor]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view setContentMode:UIViewContentModeCenter];

    [self hide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public ()

- (void)show {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self.view setAlpha:1.0];
    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:YES];
}

- (void)hide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self.view setAlpha:0.0];
    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:NO];
}

- (BOOL)isOpen{
    return self.view.userInteractionEnabled;
}
@end
