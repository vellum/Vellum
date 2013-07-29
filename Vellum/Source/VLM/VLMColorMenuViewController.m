//
//  VLMColorMenuViewController.m
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import "VLMColorMenuViewController.h"
#import "VLMConstants.h"
#import "VLMCircleMaskedView.h"

@interface VLMColorMenuViewController ()
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation VLMColorMenuViewController
@synthesize buttons;

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

    buttons = [[NSMutableArray alloc] init];

    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setAlpha:0.0f];
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;

    CGFloat margin = 0.0f;
    CGFloat innermargin = 3.0f;
    CGFloat pad = 1;
    CGFloat buttonsize = 75.0f;
    
    CGPoint topleft;
    topleft = CGPointMake(innermargin, innermargin);
        
    [self.view setFrame:CGRectMake(0.0f, HEADER_HEIGHT + buttonsize + 2*innermargin + 5.0f, winw, buttonsize + margin*2 + innermargin*2)];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view setContentMode:UIViewContentModeCenter];

    for ( int i = 0; i < 10; i++){
        VLMCircleMaskedView *circle = [[VLMCircleMaskedView alloc] initWithFrame:CGRectMake(i * 75, 0, buttonsize, buttonsize)];
        [circle setTag:i];
        [self.view addSubview:circle];
        [buttons addObject:circle];
    }
    
    
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

    for ( int i = 0; i < [self.buttons count]; i++){
        VLMCircleMaskedView *circle = (VLMCircleMaskedView*)[self.buttons objectAtIndex:i];
        [circle show];
    }

    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:YES];
}

- (void)hide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self.view setAlpha:0.0];
    for ( int i = 0; i < [self.buttons count]; i++){
        VLMCircleMaskedView *circle = (VLMCircleMaskedView*)[self.buttons objectAtIndex:i];
        [circle hide];
    }
    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:NO];
}

- (BOOL)isOpen{
    return self.view.userInteractionEnabled;
}
@end
