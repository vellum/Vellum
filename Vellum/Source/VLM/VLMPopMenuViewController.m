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
#import "VLMScrollView.h"
#import "VLMConstants.h"

@interface VLMPopMenuViewController ()
@property (nonatomic, strong) NSMutableArray *toolbuttons;
- (void)menuItemTapped:(id)sender;
@end

@implementation VLMPopMenuViewController
@synthesize toolbuttons;
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
    
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    CGSize triangleSize = CGSizeMake(16, 8);
    CGFloat margin = 0.0f;
    CGFloat innermargin = 3.0f;
    CGFloat pad = 1;
    CGFloat buttonsize = 75.0f;//(320 - margin * 2 - innermargin * 2 - pad * 2) / 3;
    CGPoint topleft;
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    VLMToolCollection *tools = [VLMToolCollection instance];
    UIView *back;
    VLMScrollView *sv;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        topleft = CGPointMake(innermargin, innermargin);

        [self.view setFrame:CGRectMake(0.0f, HEADER_HEIGHT, winw, buttonsize + margin*2 + innermargin*2)];
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.view setContentMode:UIViewContentModeCenter];
        
        back = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, winw - margin * 2, innermargin * 2 + buttonsize * 1)];
        UIView *topborder = [[UIView alloc] initWithFrame:CGRectMake(0, -1, self.view.frame.size.width, 1.0f)];
        [topborder setBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
        [topborder setUserInteractionEnabled:NO];
        [topborder setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        [back addSubview:topborder];
        [back setBackgroundColor:[UIColor whiteColor]];
        [back setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [back setContentMode:UIViewContentModeCenter];
        
        [self.view addSubview:back];
        
        sv = [[VLMScrollView alloc] initWithFrame:back.frame];
        CGFloat contentwidth =[tools.tools count]*(buttonsize+1) + 2*innermargin;
        if ( contentwidth < winw ){
            contentwidth = winw;
        }
        [sv setContentSize:CGSizeMake(contentwidth, 2*innermargin + buttonsize)];
        [sv setBackgroundColor:[UIColor clearColor]];
        [sv setCanCancelContentTouches:YES];
        [sv setAlwaysBounceHorizontal:YES];
        [sv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [sv setContentMode:UIViewContentModeCenter];
        [self.view addSubview:sv];

    } else {
        margin = 10.0f;
        innermargin = 5.0f;
        topleft = CGPointMake(0, innermargin);
        
        CGFloat popw = winw;
        CGFloat contentw = [tools.tools count] * (buttonsize+pad) + 2*innermargin + 2*margin;
        if ( contentw < popw ){
            popw = contentw;
        }
        [self.view setFrame:CGRectMake((winw-popw)/2.0f, HEADER_HEIGHT, popw, buttonsize + margin*2 + innermargin*2)];
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin];
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        
        VLMTriangleView *tri = [[VLMTriangleView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - triangleSize.width / 2, margin - triangleSize.height, triangleSize.width, triangleSize.height)];
        [self.view addSubview:tri];
        back = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, popw - margin * 2, innermargin * 2 + buttonsize * 1)];
        [back setBackgroundColor:[UIColor whiteColor]];
        
        [self.view addSubview:back];
        
        sv = [[VLMScrollView alloc] initWithFrame:CGRectMake(margin+innermargin, back.frame.origin.y, back.frame.size.width-2*innermargin, back.frame.size.height)];
        [sv setContentSize:CGSizeMake(contentw-2*margin-2*innermargin, 2*innermargin + buttonsize)];
        [sv setBackgroundColor:[UIColor clearColor]];
        [sv setCanCancelContentTouches:YES];
        [sv setAlwaysBounceHorizontal:YES];
        [sv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [sv setContentMode:UIViewContentModeCenter];
        [self.view addSubview:sv];
    }

    for (int i = 0; i < [tools.tools count]; i++) {
        CGFloat x = topleft.x + i * (buttonsize+1);//topleft.x + (i % 3) * (buttonsize + 1);
        CGFloat y = topleft.y;//topleft.y + floor(i / 3) * (buttonsize + 1);
        CGRect r = CGRectMake(x, y, buttonsize, buttonsize);
        VLMToolData *tool = (VLMToolData *)(tools.tools[i]);
        
        VLMMenuButton *item = [[VLMMenuButton alloc] initWithFrame:r];
        [item setSelected:tool.selected];
        [item setUserInteractionEnabled:!tool.selected];
        [item setText:tool.name];
        [item setTag:i];
        //[back addSubview:item];
        [sv addSubview:item];
        [buttons addObject:item];
        [item addTarget:self action:@selector(menuItemTapped:) forControlEvents:UIControlEventTouchUpInside];
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
    [UIView setAnimationDuration:0.25];
    [self.view setAlpha:1.0];
    [UIView commitAnimations];
    [self.view setUserInteractionEnabled:YES];
}

- (void)hide {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.25];
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


@end
