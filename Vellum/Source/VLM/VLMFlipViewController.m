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
    
    UIView *h = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
    [h setBackgroundColor:[UIColor colorWithPatternImage:NAVIGATION_HEADER_BACKGROUND_IMAGE]];
    [h setClipsToBounds:YES];
    [self.view addSubview:h];
    [self setHeader:h];
    
    texts = [NSArray arrayWithObjects:
             @"Draw with one finger.",
             @"Tap header for palette.",
             @"Tap to toggle header.",
             @"Pinch to zoom.",
             @"Double-tap to reset zoom.",
             //@"Tap Plus to Start Again",
             @"Long-press \"+\" to start\n from saved drawing.",
             @"Vertical-Pan with 3 fingers to undo.",
             nil];
    
    images = [NSArray arrayWithObjects:
              @"vellumhelp-01.png",
              @"vellumhelp-02.png",
              @"vellumhelp-08.png",
              @"vellumhelp-03.png",
              @"vellumhelp-04.png",
              //@"vellumhelp-05.png",
              @"vellumhelp-06.png",
              @"vellumhelp-07.png",
              nil];

    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectOffset(h.frame, 0, 0.0f)];
    [titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    [titlelabel setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
    [titlelabel setText:@"About"];
    [titlelabel setUserInteractionEnabled:NO];
    [titlelabel setTextAlignment:NSTextAlignmentCenter];
    [titlelabel setBackgroundColor:[UIColor clearColor]];
    [h addSubview:titlelabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60.0f, 0, 60.0f, HEADER_HEIGHT)];
    [button setFrame:CGRectOffset(button.frame, 0, 2.0f)];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
    [button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
    [h addSubview:button];
    [button addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height-HEADER_HEIGHT)];
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
    return texts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 380;
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




@end
