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

@interface VLMFlipViewController ()
@property (nonatomic,strong) UIView *header;
@property (nonatomic,strong) UIButton *donebutton;
@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic,strong) NSArray *texts;
@property (nonatomic,strong) NSArray *images;
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
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
    texts = [NSArray arrayWithObjects:
             @"Draw with one finger.",
             @"Tap header for palette.",
             @"Tap to toggle header.",
             @"Pinch to zoom.",
             @"Double-tap to reset zoom.",
             @"Long-press \xE2\x80\x9C+\xE2\x80\x9D to start\n from saved drawing.",
             @"Pan vertically with 3 fingers to undo.",
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
    [titlelabel setText:@"Info"];
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
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        
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

#pragma mark - UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        return texts.count-1;
    }*/
    
    return texts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 600;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int ind = indexPath.row;

    VLMTableViewCell *cell = (VLMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
            cell = [[VLMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell setTitleText:texts[ind]];
    [cell setContentImage:images[ind]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
