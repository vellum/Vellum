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
#import "VLMMenuButton.h"
#import "VLMTableView.h"
#import <QuartzCore/QuartzCore.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface VLMFlipViewController ()
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIButton *donebutton;
@property (nonatomic, weak) VLMTableView *tableview;
@property (nonatomic, strong) NSArray *texts;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;
@property (nonatomic, strong) NSArray *attributedtexts;
@property (nonatomic, strong) UIImageView *cover;
@property CGRect coverframe;

@end

@implementation VLMFlipViewController

@synthesize header;
@synthesize donebutton;
@synthesize tableview;
@synthesize texts;
@synthesize images;
@synthesize attributedtexts;
@synthesize cover;
@synthesize coverframe;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.contentSizeForViewInPopover = CGSizeMake(320.0, 578.0 - 60);
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	// Improve scrolling performance by reusing UITableView section headers
	self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
    
	// Do any additional setup after loading the view.
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
	texts = [NSArray arrayWithObjects:
	         @"PAN to draw.",
	         @"TAP HEADER to toggle palette.",
	         @"TAP ELSEWHERE to toggle header.",
	         @"TAP WITH 2 FINGERS to toggle palette.",
	         @"PINCH to zoom.",
	         @"DOUBLE-TAP to reset zoom.",
	         @"LONG-PRESS \xE2\x80\x9C+\xE2\x80\x9D to start\n from saved drawing.",
	         @"TAP SELECTED tool to toggle opacity menu.",
	         @"PAN HORIZONTALLY for erase modes.",
	         @"PAN VERTICALLY with 3 fingers to undo.",
	         nil];
    
	images = [NSArray arrayWithObjects:
	          @"about-01.png",
	          @"about-02.png",
	          @"about-05.png",
	          @"about-08.png",
	          @"about-03.png",
	          @"about-04.png",
	          @"about-06.png",
	          @"about-09.png",
	          @"about-10.png",
	          @"about-07.png",
	          nil];
    
	//if (NSClassFromString(@"NSMutableAttributedString")){
	//if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f) {
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && NSClassFromString(@"NSMutableAttributedString")) {
		NSArray *sctexts = [NSArray arrayWithObjects:
		                    @"PAN",
		                    @"TAP HEADER",
		                    @"TAP ELSEWHERE",
		                    @"TAP WITH 2 FINGERS",
		                    @"PINCH",
		                    @"DOUBLE-TAP",
		                    @"LONG-PRESS",
		                    @"TAP SELECTED",
		                    @"PAN HORIZONTALLY",
		                    @"PAN VERTICALLY",
		                    nil];
        
		attributedtexts = [NSArray arrayWithObjects:
		                   [[NSMutableAttributedString alloc] initWithString:@"Pan to draw."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Tap header to toggle palette."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Tap elsewhere to toggle header."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Tap with 2 fingers to toggle palette."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Pinch to zoom."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Double-tap to reset zoom."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Long-press \xE2\x80\x9C+\xE2\x80\x9D to start\n from saved drawing."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Tap selected tool to toggle opacity menu."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Pan horizontally for erase modes."],
		                   [[NSMutableAttributedString alloc] initWithString:@"Pan vertically with 3 fingers to undo."],
		                   nil];
        
        
		//UIFont *fontnormal = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
		//UIFont *fontsmallcaps = [UIFont fontWithName:@"Helvetica-Bold-Italic" size:13.0f];
        
		for (int i = 0; i < [attributedtexts count]; i++) {
			CGFloat len = [[sctexts objectAtIndex:i] length];
			NSMutableAttributedString *s = [attributedtexts objectAtIndex:i];
			//[s addAttribute:NSFontAttributeName value:fontsmallcaps range:NSMakeRange(0, len)];
			//[s addAttribute:NSFontAttributeName value:fontnormal range:NSMakeRange(len, [s length]-len)];
			[s addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.0f alpha:1.0f] range:NSMakeRange(0, len)];
			[s addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.0f alpha:0.5f] range:NSMakeRange(len, [s length] - len)];
		}
	}
    
	VLMTableView *tv;
    
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		UIView *h = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEADER_HEIGHT)];
		[h setBackgroundColor:[UIColor colorWithPatternImage:NAVIGATION_HEADER_BACKGROUND_IMAGE]];
		[h setClipsToBounds:YES];
		[self.view addSubview:h];
		[self setHeader:h];
        
		UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectOffset(CGRectMake(0, 0, h.frame.size.width, h.frame.size.height), 0, 0.0f)];
		[titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
		[titlelabel setTextColor:[UIColor colorWithWhite:0.2f alpha:1.0f]];
		[titlelabel setText:@"About"];
		[titlelabel setUserInteractionEnabled:YES];
		[titlelabel setTextAlignment:NSTextAlignmentCenter];
		[titlelabel setBackgroundColor:[UIColor clearColor]];
		[self.header addSubview:titlelabel];
        
		UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
		[tgr setNumberOfTapsRequired:1];
		[tgr setNumberOfTouchesRequired:1];
		[titlelabel addGestureRecognizer:tgr];
        
        
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(h.frame.size.width - 60.0f, 0, 60.0f, HEADER_HEIGHT)];
		[button setFrame:CGRectOffset(button.frame, 0, 1.0f)];
		[button setTitle:@"Done" forState:UIControlStateNormal];
		[button setTitleColor:[UIColor colorWithWhite:0.2f alpha:1.0f] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
		[button setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
		[button setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
		[button setContentMode:UIViewContentModeTopRight];
		[self.header addSubview:button];
		[button addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        
		tv = [[VLMTableView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - HEADER_HEIGHT)];
	}
	else {
		tv = [[VLMTableView alloc] initWithFrame:CGRectMake(0, 0, self.contentSizeForViewInPopover.width, self.contentSizeForViewInPopover.height)];
	}
	tv.delegate = self;
	tv.dataSource = self;
	self.tableview = tv;
	self.tableview.backgroundColor = [UIColor clearColor];
	self.tableview.separatorColor = [UIColor clearColor];
	[self.tableview setCanCancelContentTouches:YES];
    
	[self.view addSubview:self.tableview];
    
	NSArray *buttonTitles = [NSArray arrayWithObjects:
	                         @"Rate on App Store",
	                         @"Follow @vellumapp",
	                         @"Suggest idea",
	                         @"Gestures (New)",
	                         nil];
    
	CGFloat margin = 25.0f;
	CGFloat buttonheight = 55.0f;
	CGFloat buttonspacing = 5.0f;
    
    
	UIView *tvHeader = [[UIView alloc] initWithFrame:tv.frame];
	[tvHeader setBackgroundColor:[UIColor colorWithHue:60.0f / 360.0f saturation:0.04f brightness:0.95f alpha:1.0f]];
	[tvHeader setAutoresizingMask:UIViewAutoresizingNone];
	[tvHeader setAutoresizesSubviews:NO];
	[tvHeader setUserInteractionEnabled:YES];
    
    
	UIImage *albumcover = [UIImage imageNamed:@"albumcover.png"];
	UIImageView *albumview = [[UIImageView alloc] initWithImage:albumcover];
	CGRect pf = CGRectMake(0, HEADER_HEIGHT, 320, 280.0f);
	if (tv.frame.size.height <= 420) {
		pf = CGRectMake(0, HEADER_HEIGHT, 320, 140.0f);
	}
	[albumview setFrame:pf];
	[albumview setContentMode:UIViewContentModeScaleAspectFill];
	[albumview setUserInteractionEnabled:NO];
	[albumview setAutoresizingMask:UIViewAutoresizingNone];
	[albumview setAutoresizesSubviews:NO];
	[tvHeader addSubview:albumview];
    
	self.coverframe = albumview.frame;
	self.cover = albumview;
    
	UIButton *cap = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tvHeader.frame.size.width, tvHeader.frame.size.height)];
	[cap setBackgroundColor:[UIColor clearColor]];
	[tvHeader addSubview:cap];
    
	CGFloat vmargintop = tvHeader.frame.size.height - [buttonTitles count] * (buttonheight + buttonspacing) - margin;
	for (CGFloat i = 0; i < [buttonTitles count]; i++) {
		UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(margin, vmargintop + i * (buttonheight + buttonspacing), 320 - margin * 2, buttonheight)];
		[btn setBackgroundColor:[UIColor clearColor]];
		[btn setTitleColor:[UIColor colorWithWhite:0.0f alpha:0.8f] forState:UIControlStateNormal];
		[btn setBackgroundImage:[UIImage imageNamed:@"black.png"] forState:UIControlStateHighlighted];
		[btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f]];
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		[btn setBackgroundImage:[UIImage imageNamed:@"black.png"] forState:UIControlStateHighlighted];
        
		NSString *text = buttonTitles[(int)i];
		[btn setTitle:[text uppercaseString] forState:UIControlStateNormal];
		[btn setTag:i];
		[btn addTarget:self action:@selector(handleTappie:) forControlEvents:UIControlEventTouchUpInside];
		[tvHeader addSubview:btn];
        
		CALayer *layer = [btn layer];
		[layer setMasksToBounds:YES];
		[layer setCornerRadius:0.0f];
		[layer setBorderWidth:4.0f];
		[layer setBorderColor:[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
	}
	[tv setTableHeaderView:tvHeader];
    
	self.cover.frame = CGRectMake(0, 0, self.coverframe.size.width, self.coverframe.size.height);
	self.cover.center = CGPointMake(tv.center.x, self.cover.center.y);
    
    
	UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hoswipe:)];
	[sgr setDirection:UISwipeGestureRecognizerDirectionRight];
	[self.view addGestureRecognizer:sgr];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)done {
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	NSString *text = texts[section];
	return [VLMSectionView expectedViewHeightForText:text];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	VLMSectionView *customview = [self dequeueReusableSectionHeaderView];
	if (!customview) {
		customview = [[VLMSectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 60.0f)];
		[self.reusableSectionHeaderViews addObject:customview];
	}
	[customview reset];
	//if (NSClassFromString(@"NSMutableAttributedString")){
	if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && NSClassFromString(@"NSMutableAttributedString")) {
		NSMutableAttributedString *text = attributedtexts[section];
		[customview setAttributedText:text];
	}
	else {
		NSString *text = texts[section];
		[customview setText:text];
	}
	return customview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 550;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	int ind = indexPath.section;
    
	VLMTableViewCell *cell = (VLMTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[VLMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	[cell setContentImage:images[ind]];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (VLMSectionView *)dequeueReusableSectionHeaderView {
	for (VLMSectionView *sectionHeaderView in self.reusableSectionHeaderViews) {
		if (!sectionHeaderView.superview) {
			// we found a section header that is no longer visible
			return sectionHeaderView;
		}
	}
	return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat y = -scrollView.contentOffset.y;
	if (y >= 0) {
		self.cover.frame = CGRectMake(0, scrollView.contentOffset.y, self.coverframe.size.width + y, self.coverframe.size.height + y);
		self.cover.center = CGPointMake(self.view.center.x, self.cover.center.y);
	}
}

#pragma mark GestureRecco

- (void)tapped:(UIGestureRecognizer *)sender {
	//NSLog(@"tapped");
	[self.tableview scrollRectToVisible:CGRectMake(0, 1, 1, 1) animated:YES];
}

- (void)handleTappie:(id)sender {
	UIButton *b = (UIButton *)sender;
	int tag = b.tag;
	NSIndexPath *ipath = [NSIndexPath indexPathForRow:0 inSection:0];
	switch (tag) {
		case 0:
			//NSLog(@"rate");
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=338779283"]];
			break;
            
		case 1:
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=vellumapp"]];
			}
			else {
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/vellumapp"]];
			}
			break;
            
		case 2:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://vellum.uservoice.com"]];
			break;
            
		case 3:
			[self.tableview scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:YES];
			break;
	}
}

#pragma mark - Rotation Handling
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if (interfaceOrientation == UIInterfaceOrientationMaskPortrait) {
			return YES;
		}
		return NO;
	}
	else {
		return YES;
	}
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskPortrait;
	}
	else {
		return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
	}
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

# pragma mark - swipe recco
- (void)hoswipe:(id)sender {
	[self done];
}

@end
