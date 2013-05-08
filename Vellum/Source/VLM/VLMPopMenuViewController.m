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
#import "VLMToolCollection.h"
#import "VLMToolData.h"

@interface VLMPopMenuViewController ()
@property (nonatomic,strong) NSMutableArray *toolbuttons;
@property (nonatomic,strong) NSMutableArray *onoffbuttons;
@end

@implementation VLMPopMenuViewController
@synthesize toolbuttons;
@synthesize onoffbuttons;
@synthesize delegate;

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
    
    VLMToolCollection *tools = [VLMToolCollection instance];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [tools.tools count]; i++) {
        CGFloat x = topleft.x + (i%3) * (buttonsize+1);
        CGFloat y = topleft.y + floor(i/3) * (buttonsize+1);
        CGRect r = CGRectMake(x, y, buttonsize, buttonsize);
        VLMToolData *tool = (VLMToolData *)(tools.tools[i]);
        
        VLMMenuButton *item = [[VLMMenuButton alloc] initWithFrame:r];
        [item setSelected:tool.selected];
        [item setUserInteractionEnabled:!tool.selected];
        [item setText:tool.name];
        [item setTag:i];
        [back addSubview:item];
        [buttons addObject:item];
        [item addTarget:self action:@selector(menuItemTapped:) forControlEvents:UIControlEventTouchUpInside];

        UIButton *onoff = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
        [onoff setBackgroundImage:[UIImage imageNamed:@"popcircle_off.png"] forState:UIControlStateNormal];
        [onoff setBackgroundImage:[UIImage imageNamed:@"popcircle_on.png"] forState:UIControlStateSelected];
        [onoff setSelected:tool.enabled];
        [onoff setTag:i];
        [onoff setShowsTouchWhenHighlighted:YES];
        [back addSubview:onoff];
        [onoff addTarget:self action:@selector(onofftapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [onoffbuttons addObject:onoff];
        
    }
    [self.view setAlpha:0.0];
    [self.view setUserInteractionEnabled:NO];
    self.toolbuttons = buttons;
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

-(void)menuItemTapped:(id)sender{
    VLMMenuButton *mb = (VLMMenuButton *)sender;
    NSInteger tag = mb.tag;
    
    // update data
    VLMToolCollection *tools = [VLMToolCollection instance];
    for (VLMToolData *item in tools.tools) {
        item.selected = NO;
    }
    tools.selectedIndex = tag;
    VLMToolData *selecteditem = (VLMToolData *)[tools.tools objectAtIndex:tag];
    selecteditem.selected = YES;
    
    // update buttons
    [self updatebuttons];

    // update toolheader (and glview)
    if (self.delegate != nil) {
        if (selecteditem.enabled)
            [self.delegate updateHeader];
        else
            [self.delegate updateHeaderWithTitle:selecteditem.name];
        
    }
    
}

-(void)onofftapped:(id)sender{
    UIButton *b = (UIButton *)sender;
    NSInteger tag = b.tag;
    NSLog(@"tapped: %d", tag);

    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *item = (VLMToolData *)[tools.tools objectAtIndex:tag];
    item.enabled = !item.enabled;
    [b setSelected:item.enabled];

    //update header
    [self.delegate refreshData];
}

-(void)updatebuttons{
    for ( VLMMenuButton *b in self.toolbuttons ){
        b.userInteractionEnabled = YES;
        b.selected = NO;
    }
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMMenuButton *mb = (VLMMenuButton *) [self.toolbuttons objectAtIndex:tools.selectedIndex];
    mb.userInteractionEnabled = NO;
    mb.selected = YES;    
}

@end
