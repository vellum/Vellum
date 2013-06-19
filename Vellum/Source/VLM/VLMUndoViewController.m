//
//  VLMUndoViewController.m
//  Vellum
//
//  Created by David Lu on 5/11/13.
//
//

#import "VLMUndoViewController.h"
#import "VLMArcView.h"
#import <QuartzCore/QuartzCore.h>


@interface VLMUndoViewController ()
@property (nonatomic, strong) VLMArcView *arcView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation VLMUndoViewController
@synthesize index;
@synthesize numStates;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setIndex:0];
    [self setNumStates:1];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    [self.view setAlpha:0];
    [self.view setUserInteractionEnabled:NO];
    [self.view setFrame:bounds];
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setClipsToBounds:YES];
    
    CGFloat diameter = 120;
    CGRect rect = CGRectMake(bounds.size.width / 2 - diameter / 2, 99, diameter, diameter);
    [self setArcView:[[VLMArcView alloc] initWithFrame:rect]];
    [self.arcView setAlpha:0.9f];
    [self.view addSubview:self.arcView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:rect];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont boldSystemFontOfSize:18.0f]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setText:@"Undo"];
    [lbl setAdjustsFontSizeToFitWidth:YES];
    [self.view addSubview:lbl];
    
    
    [self.view.layer setZPosition:1001.0f];
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
    [UIView setAnimationDuration:0.2];
    [self.view setAlpha:1.0];
    [UIView commitAnimations];
}

- (void)hide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    [self.view setAlpha:0.0];
    [UIView commitAnimations];
}

- (BOOL)isVisible {
    return (self.view.alpha == 1.0f);
}

- (void)update{
    NSLog(@"undoviewcontroller: update()");
    [self.arcView setIndex:self.index];
    [self.arcView setNeedsDisplay];
}
@end
