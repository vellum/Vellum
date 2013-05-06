//
//  VLMPopMenuViewController.m
//  Ejecta
//
//  Created by David Lu on 5/5/13.
//
//

#import "VLMPopMenuViewController.h"
#import "VLMTriangleView.h"
#import "VLMPopMenuViewController.h"
#import "VLMMenuButton.h"

@interface VLMPopMenuViewController ()

@end

@implementation VLMPopMenuViewController

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
	// Do any additional setup after loading the view.

    CGFloat HEADER_HEIGHT = 60.0f;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    
    [self.view setFrame:CGRectMake(winw/2.0f-320.0f/2.0f, HEADER_HEIGHT, 320, 230)];
    
    CGSize triangleSize = CGSizeMake(16,8);
    CGFloat margin = 10.0f;
    VLMTriangleView *tri = [[VLMTriangleView alloc] initWithFrame:CGRectMake(320/2-triangleSize.width/2, margin - triangleSize.height, triangleSize.width, triangleSize.height)];
    [self.view addSubview:tri];
    

    CGFloat innermargin = 5;
    CGFloat pad = 1;
    CGFloat buttonsize = (320 - margin*2 - innermargin*2 - pad*2)/3;
    CGPoint topleft = CGPointMake(innermargin,innermargin);

    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, 320-margin*2, innermargin*2+pad+buttonsize*2)];
    back.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:back];
    
    NSArray *names = [NSArray arrayWithObjects:@"Lines", @"Dots", @"Ink", @"Scratch", nil];
    for (int i = 0;i < names.count; i++){
        CGFloat x = topleft.x + (i%3) * (buttonsize+1);
        CGFloat y = topleft.y + floor(i/3) * (buttonsize+1);
        CGRect r = CGRectMake(x, y, buttonsize, buttonsize);
        VLMMenuButton *item = [[VLMMenuButton alloc] initWithFrame:r];
        if ( i == 0 ) {
            [item setSelected:YES];
            [item setUserInteractionEnabled:NO];
        }
        [item setText:names[i]];
        [back addSubview:item];
    }
 
    [self.view setAlpha:0.0];
    [self.view setUserInteractionEnabled:NO];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)show
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	[self.view setAlpha:1.0];
	[UIView commitAnimations];
    [self.view setUserInteractionEnabled:YES];
}

-(void)hide
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3];
	[self.view setAlpha:0.0];
	[UIView commitAnimations];
    [self.view setUserInteractionEnabled:NO];
}

@end
