//
//  VLMFlipViewController.m
//  Vellum
//
//  Created by David Lu on 6/13/13.
//
//

#import "VLMFlipViewController.h"
#import "VLMConstants.h"
#import "VLMTableViewCell.h"
#import "VLMSectionView.h"

@interface VLMFlipViewController ()
@property (nonatomic,strong) UIView *header;
@property (nonatomic,strong) UIButton *donebutton;
@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic,strong) NSArray *texts;
@property (nonatomic,strong) NSArray *images;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;

@end

@implementation VLMFlipViewController

@synthesize header;
@synthesize donebutton;
@synthesize tableview;
@synthesize texts;
@synthesize images;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 525.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Improve scrolling performance by reusing UITableView section headers
    self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];

	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
    texts = [NSArray arrayWithObjects:
             @"PAN ANYWHERE to draw.",
             @"TAP HEADER for palette.",
             @"TAP ANYWHERE to toggle header.",
             @"PINCH to zoom.",
             @"DOUBLE-TAP ANYWHERE to reset zoom.",
             @"LONG-PRESS \xE2\x80\x9C+\xE2\x80\x9D to start\n from saved drawing.",
             @"PAN VERTICALLY with 3 fingers to undo.",
             nil];
    
    images = [NSArray arrayWithObjects:
              @"about-01.png",
              @"about-02.png",
              @"about-05.png",
              @"about-03.png",
              @"about-04.png",
              @"about-06.png",
              @"about-07.png",
              nil];
    UITableView *tableView;
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        
        UIView *h = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
        [h setBackgroundColor:[UIColor colorWithPatternImage:NAVIGATION_HEADER_BACKGROUND_IMAGE]];
        [h setClipsToBounds:YES];
        [self.view addSubview:h];
        [self setHeader:h];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectOffset(CGRectMake(0, 0, h.frame.size.width, h.frame.size.height), 0, 0.0f)];
        [titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
        [titlelabel setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
        [titlelabel setText:@"Gestures"];
        [titlelabel setUserInteractionEnabled:YES];
        [titlelabel setTextAlignment:NSTextAlignmentCenter];
        [titlelabel setBackgroundColor:[UIColor clearColor]];
        [self.header addSubview:titlelabel];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [tgr setNumberOfTapsRequired:1];
        [tgr setNumberOfTouchesRequired:1];
        [titlelabel addGestureRecognizer:tgr];
        

        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(h.frame.size.width-60.0f, 0, 60.0f, HEADER_HEIGHT)];
        [button setFrame:CGRectOffset(button.frame, 0, 2.0f)];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
        [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
        [button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [button setContentMode:UIViewContentModeTopRight];
        [self.header addSubview:button];
        [button addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];

    } else {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height)];
        
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableview = tableView;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.separatorColor = [UIColor clearColor];

    [self.view addSubview:self.tableview];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    [self.delegate flipsideViewControllerDidFinish:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sections = self.texts.count;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sections--; // omit undo slide
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

#pragma mark - UITableView Delegate Methods



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    NSString *text = texts[section];
    return [VLMSectionView expectedViewHeightForText:text];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    NSString *text = texts[section];
    CGFloat winw = 320.0f;
    VLMSectionView *customview = [self dequeueReusableSectionHeaderView];
    if (!customview){
        customview = [[VLMSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 60.0f)];
        [self.reusableSectionHeaderViews addObject:customview];
        
    }
    [customview reset];
    [customview setText:text];
    return customview;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 550;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int ind = indexPath.section;

    VLMTableViewCell *cell = (VLMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
            cell = [[VLMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setContentImage:images[ind]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}
- (VLMSectionView *)dequeueReusableSectionHeaderView{
    for (VLMSectionView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    return nil;
}


#pragma mark GestureRecco

- (void)tapped:(UIGestureRecognizer *)sender{
    NSLog(@"tapped");
    [self.tableview scrollRectToVisible:CGRectMake(0,1,1,1) animated:YES];
}

#pragma mark - Rotation Handling
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (interfaceOrientation==UIInterfaceOrientationMaskPortrait){
            return YES;
        }
        return NO;
    } else {
        return YES;
    }
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
