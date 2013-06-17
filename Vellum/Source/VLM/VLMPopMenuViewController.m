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
@property (nonatomic, strong) NSMutableArray *toolbuttons;
@property (nonatomic, strong) NSMutableArray *onoffbuttons;
- (void)onofftapped:(id)sender;
- (void)menuItemTapped:(id)sender;
@end

@implementation VLMPopMenuViewController
@synthesize toolbuttons;
@synthesize onoffbuttons;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat HEADER_HEIGHT = 60.0f; //FIXME: HEADER_HEIGHT should be a constant
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGSize triangleSize = CGSizeMake(16, 8);
    CGFloat margin = 10.0f;
    CGFloat innermargin = 5;
    CGFloat pad = 1;
    CGFloat buttonsize = (320 - margin * 2 - innermargin * 2 - pad * 2) / 3;
    CGPoint topleft = CGPointMake(innermargin, innermargin);
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    VLMToolCollection *tools = [VLMToolCollection instance];
    
    VLMTriangleView *tri = [[VLMTriangleView alloc] initWithFrame:CGRectMake(320 / 2 - triangleSize.width / 2, margin - triangleSize.height, triangleSize.width, triangleSize.height)];
    
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, 320 - margin * 2, innermargin * 2 + pad + buttonsize * 2)];
    [back setBackgroundColor:[UIColor whiteColor]];
    
    [self.view setFrame:CGRectMake(winw / 2.0f - 320.0f / 2.0f, HEADER_HEIGHT, 320, 230)];
    [self.view addSubview:tri];
    [self.view addSubview:back];
    
    for (int i = 0; i < [tools.tools count]; i++) {
        CGFloat x = topleft.x + (i % 3) * (buttonsize + 1);
        CGFloat y = topleft.y + floor(i / 3) * (buttonsize + 1);
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

        // removing this for now, people seem to not get it.
        //[back addSubview:onoff];
        [onoff addTarget:self action:@selector(onofftapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [onoffbuttons addObject:onoff];
    }
    [self.view setAlpha:0.0];
    [self.view setUserInteractionEnabled:NO];
    [self setToolbuttons:buttons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public ()

- (void)show {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [self.view setAlpha:1.0];
    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:YES];
}

- (void)hide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [self.view setAlpha:0.0];
    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:NO];
}

- (void)updatebuttons {
    for (VLMMenuButton *b in self.toolbuttons) {
        [b setUserInteractionEnabled:YES];
        [b setSelected:NO];
    }
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMMenuButton *mb = (VLMMenuButton *)[self.toolbuttons objectAtIndex:tools.selectedIndex];
    [mb setUserInteractionEnabled:NO];
    [mb setSelected:YES];
}

#pragma mark - private ()

- (void)menuItemTapped:(id)sender {
    VLMMenuButton *mb = (VLMMenuButton *)sender;
    NSInteger tag = mb.tag;
    
    // update data
    VLMToolCollection *tools = [VLMToolCollection instance];
    for (VLMToolData *item in tools.tools) {
        [item setSelected:NO];
    }
    [tools setSelectedIndex:tag];
    VLMToolData *selecteditem = (VLMToolData *)[tools.tools objectAtIndex:tag];
    [selecteditem setSelected:YES];
    
    // update buttons
    [self updatebuttons];
    
    // update toolheader (and glview)
    if (self.delegate != nil) {
        if (selecteditem.enabled) [self.delegate updateHeader];
        else [self.delegate updateHeaderWithTitle:selecteditem.name];
    }
}

- (void)onofftapped:(id)sender {
    UIButton *b = (UIButton *)sender;
    NSInteger tag = b.tag;
    
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *item = (VLMToolData *)[tools.tools objectAtIndex:tag];
    [item setEnabled:!item.enabled];
    [b setSelected:item.enabled];
    
    //update header
    [self.delegate refreshData];
}

@end
