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
#import "VLMOpaButton.h"


@interface VLMPopMenuViewController ()
@property (nonatomic, strong) NSMutableArray *toolbuttons;
@property (nonatomic, strong) NSMutableArray *opabuttons;
- (void)menuItemTapped:(id)sender;
@end

@implementation VLMPopMenuViewController
@synthesize toolbuttons;
@synthesize opabuttons;
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
    
	VLMToolCollection *tools = [VLMToolCollection instance];
	NSMutableArray *buttons = [[NSMutableArray alloc] init];
	NSMutableArray *opas = [[NSMutableArray alloc] init];
	[self setToolbuttons:buttons];
	[self setOpabuttons:opas];
    
	CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
	CGSize triangleSize = CGSizeMake(16, 8);
	CGFloat margin = 0.0f;
	CGFloat innermargin = 3.0f;
	CGFloat pad = 1;
	CGFloat buttonsize = 74.0f;
    
	CGPoint topleft;
	UIView *back;
	VLMScrollView *sv;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		topleft = CGPointMake(innermargin, innermargin);
        
		[self.view setFrame:CGRectMake(0.0f, HEADER_HEIGHT, winw, buttonsize + margin * 2 + innermargin * 2)];
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
		CGFloat contentwidth = [tools.tools count] * (buttonsize + 1) + 2 * innermargin;
		if (contentwidth < winw) {
			contentwidth = winw;
		}
		[sv setContentSize:CGSizeMake(contentwidth, 2 * innermargin + buttonsize)];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setCanCancelContentTouches:YES];
		[sv setAlwaysBounceHorizontal:YES];
		[sv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[sv setContentMode:UIViewContentModeCenter];
        
		[sv setShowsHorizontalScrollIndicator:NO];
		[sv setShowsVerticalScrollIndicator:NO];

        UIView *pattern = [[UIView alloc] initWithFrame:CGRectMake(sv.frame.origin.x+innermargin, sv.frame.origin.y+innermargin, sv.frame.size.width-innermargin*2-1, sv.frame.size.height-innermargin*2)];
        [pattern setUserInteractionEnabled:NO];
        [pattern setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
        [self.view addSubview:pattern];

		[self.view addSubview:sv];
        
        //[sv setDelegate:self];
	}
	else {
        buttonsize = 73.0f;
		margin = 10.0f;
        CGFloat marginhoz = 10;
		innermargin = 5.0f;
		topleft = CGPointMake(0, innermargin);
        
        
        CGFloat popw = winw;
		CGFloat contentw = [tools.tools count] * (buttonsize + pad);
        
        
		[self.view setFrame:CGRectMake((winw - popw) / 2.0f, HEADER_HEIGHT, popw, buttonsize + margin * 2 + innermargin * 2)];

		[self.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		[self.view setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        
		VLMTriangleView *tri = [[VLMTriangleView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - triangleSize.width / 2, margin - triangleSize.height, triangleSize.width, triangleSize.height)];
		[self.view addSubview:tri];
        
		back = [[UIView alloc] initWithFrame:CGRectMake(marginhoz, margin, winw - marginhoz*2, innermargin * 2 + buttonsize * 1)];
        [back setBackgroundColor:[UIColor whiteColor]];
        
		[self.view addSubview:back];
        
		sv = [[VLMScrollView alloc] initWithFrame:CGRectMake(
                 marginhoz + innermargin,
                 back.frame.origin.y,
                 winw - 2 * marginhoz - 2 * innermargin,
                 back.frame.size.height)];
		[sv setContentSize:CGSizeMake(contentw - 2 * margin - 2 * innermargin, 2 * innermargin + buttonsize)];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setCanCancelContentTouches:YES];
		[sv setAlwaysBounceHorizontal:YES];
		[sv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[sv setContentMode:UIViewContentModeCenter];
		
        
        UIView *pattern = [[UIView alloc] initWithFrame:CGRectMake(sv.frame.origin.x, sv.frame.origin.y+innermargin, sv.frame.size.width, sv.frame.size.height-innermargin*2)];
        [pattern setUserInteractionEnabled:NO];
        [pattern setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
        [self.view addSubview:pattern];
        [self.view addSubview:sv];
        
        
	}
    
	for (int i = 0; i < [tools.tools count]; i++) {
		CGFloat x = topleft.x + i * (buttonsize + 1);
		CGFloat y = topleft.y;
		CGRect r = CGRectMake(x, y, buttonsize, buttonsize);
		VLMToolData *tool = (VLMToolData *)(tools.tools[i]);
        
		VLMMenuButton *item = [[VLMMenuButton alloc] initWithFrame:r];
		[item setSelected:tool.selected];
		[item setUserInteractionEnabled:!tool.selected];
		[item setText:tool.name];
		[item setTag:i];
		[sv addSubview:item];
		[buttons addObject:item];
		[item addTarget:self action:@selector(menuItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        if (i<[tools.tools count]-1){
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x+buttonsize, y, 1, buttonsize)];
            [line setBackgroundColor:[UIColor whiteColor]];
            [line setUserInteractionEnabled:NO];
            [sv addSubview:line];
        }
        
		NSUInteger location = [tool.name rangeOfString:@" " options:NSCaseInsensitiveSearch].location;
		VLMOpaButton *opa = [[VLMOpaButton alloc] initWithFrame:r];
		[opa setTag:i];
		[opa addTarget:self action:@selector(selectedItemTapped:) forControlEvents:UIControlEventTouchUpInside];
		[sv addSubview:opa];
		if (location != NSNotFound) {
			[opa shiftY];
		}
		[opabuttons addObject:opa];
	}
    
	[self.view setAlpha:0.0];
	[self.view setUserInteractionEnabled:NO];
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
	[UIView setAnimationDuration:ANIMATION_DURATION * 2];
	[self.view setAlpha:1.0];
	[UIView commitAnimations];
	[self.view setUserInteractionEnabled:YES];
	[self updatebuttons];
}

- (void)hide {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:ANIMATION_DURATION * 2];
	[self.view setAlpha:0.0];
	[UIView commitAnimations];
	[self.view setUserInteractionEnabled:NO];
	[self updatebuttons];
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
    
	for (VLMOpaButton *b in self.opabuttons) {
		if (b.tag != tools.selectedIndex) {
			[b hide];
		}
	}
	VLMOpaButton *op = (VLMOpaButton *)[self.opabuttons objectAtIndex:tools.selectedIndex];
	[op show];
	if ([delegate isColorMenuOpen]) {
		[op open]; // force the button into an open state
	}
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
    
	// update toolheader (and glview)
	if (self.delegate != nil) {
		if (selecteditem.enabled) [self.delegate updateHeader];
		else [self.delegate updateHeaderWithTitle:selecteditem.name];
	}
    
	[self.delegate updateColorMenu];
	// update buttons
	[self updatebuttons];
}

- (void)selectedItemTapped:(id)sender {
	//VLMOpaButton *ob = (VLMOpaButton *)sender;
	//NSInteger tag = ob.tag;
	//NSLog(@"selected item tapped : %i", tag);
	if ([self.delegate isColorMenuOpen]) {
		[self.delegate hideColorMenu];
	}
	else {
		[self.delegate showColorMenu];
	}
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)sv
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {

    // only iphone gets this treatment
    
    CGFloat pad = 1;
	CGFloat buttonsize = 74.0f;
    CGFloat innermargin = 3.0f;
    
    //NSLog(@"willenddragging %f %f", targetContentOffset->x, velocity.x);
    if (targetContentOffset->x >= sv.contentSize.width-sv.frame.size.width) return;
    if (velocity.x==0) return;
    if (targetContentOffset->x <= buttonsize + innermargin) return;
    
    
    CGFloat x = targetContentOffset->x;
    x -= innermargin;
    x = floorf( x / ( buttonsize + pad ) );
    x *= buttonsize + pad;
    x += innermargin;
    //NSLog(@"%f , %f", targetContentOffset->x, x );
    targetContentOffset->x = x;
}


@end
