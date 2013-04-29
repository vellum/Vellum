//
//  VLMDrawHeaderController.m
//  Ejecta
//
//  Created by David Lu on 4/28/13.
//
//

#import "VLMDrawHeaderController.h"
#import "DDPageControl.h"

#define HEADER_LABEL_WIDTH 175.0f

@interface VLMDrawHeaderController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIView *titleview;
@property CGRect titleframe;
@property (nonatomic, strong) DDPageControl *pagecontrol;
@property (nonatomic, strong) UIButton *plus;
@end

@implementation VLMDrawHeaderController
@synthesize titles;
@synthesize index;
@synthesize titleview;
@synthesize titleframe;
@synthesize pagecontrol;
@synthesize delegate;
@synthesize plus;

- (id) initWithHeadings:(NSArray *)headings{
    self = [self init];
    if (self){
        self.index = 0;
        self.titles = [NSArray arrayWithArray:headings];
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.index = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat HEADER_HEIGHT = 60.0f;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    self.index = 0;

	[self.view setFrame:CGRectMake(0, 0, winw, HEADER_HEIGHT)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    
    UIView *titleviewmask = [[UIView alloc] initWithFrame:CGRectMake(winw/2-HEADER_LABEL_WIDTH/2, 0, HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
    [titleviewmask setClipsToBounds:YES];
    [titleviewmask setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:titleviewmask];
    self.titleframe = CGRectMake(0, 0, 300.0f, HEADER_HEIGHT);
    self.titleview = [[UIView alloc] initWithFrame:self.titleframe];
    [titleviewmask addSubview:titleview];
    [titleview setBackgroundColor:[UIColor clearColor]];
    [self setupHeadingView];
    
    
    self.pagecontrol = [[DDPageControl alloc] init];
    [self.pagecontrol setCenter:CGPointMake(winw/2, HEADER_HEIGHT - 14 + 2)];
    [self.pagecontrol setNumberOfPages:10];
    [self.pagecontrol setCurrentPage:0];
    //[self.pagecontrol setDefersCurrentPageDisplay:YES];
    [self.pagecontrol setOnColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
    [self.pagecontrol setOffColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [self.pagecontrol setIndicatorDiameter:5.0f];
    [self.pagecontrol setIndicatorSpace:7.0f];
    [self.pagecontrol setUserInteractionEnabled:NO];
    [self.view addSubview:self.pagecontrol];

    
    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPage)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *sgr2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(prevPage)];
    [sgr2 setDirection:UISwipeGestureRecognizerDirectionRight];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [titleviewmask addGestureRecognizer:sgr];
    [titleviewmask addGestureRecognizer:sgr2];
    [titleviewmask addGestureRecognizer:tgr];

    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, HEADER_HEIGHT*0.8 f, HEADER_HEIGHT)];
    [pl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24.0f]];
    [pl setTextColor:[UIColor blackColor]];
    [pl setTextAlignment:UITextAlignmentCenter];
    [pl setBackgroundColor:[UIColor clearColor]];
    [pl setText:@"+"];
    [self.view addSubview:pl];
    
    UIButton *fb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [fb setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:fb];
    [fb addTarget:self action:@selector(plusTapped:) forControlEvents:UIControlEventTouchUpInside];

}


- (void) setHeadings:(NSArray *)headings{
    self.titles = [NSArray arrayWithArray:headings];
    [self setupHeadingView];
}

- (void) setupHeadingView{
    CGFloat HEADER_HEIGHT = 60.0f;
    int count = [self.titles count];
    [self.titleview setFrame:CGRectMake(0, 0, count*HEADER_LABEL_WIDTH, HEADER_HEIGHT)];

    NSArray* subViews = self.titleview.subviews;
    for( UIView *aView in subViews ) {
        [aView removeFromSuperview];
    }
    
    for ( int i = 0; i < [self.titles count]; i++ ){
        NSString *t = self.titles[i];
        UILabel *A = [[UILabel alloc] initWithFrame:CGRectMake(i*HEADER_LABEL_WIDTH, 0, HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
        [A setText:t];
        [A setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
        [A setTextColor:[UIColor blackColor]];
        [A setTextAlignment:UITextAlignmentCenter];
        [A setBackgroundColor:[UIColor clearColor]];
        [self.titleview addSubview:A];
    }
    [self.pagecontrol setNumberOfPages:[self.titles count]];
    [self.pagecontrol setCurrentPage:0];

}
- (void) tapped{
    self.index++;
    if (self.index > [self.titles count] - 1){
        self.index = 0;
    }
    [self.titleview setFrame:CGRectOffset(titleframe, -self.index*HEADER_LABEL_WIDTH, 0)];
    [self.pagecontrol setCurrentPage:self.index];
    if (self.delegate){
        [self.delegate updateIndex:self.index AndTitle:self.titles[self.index]];
    }

}
- (void) nextPage{
    self.index++;
    if (self.index > [self.titles count] - 1){
        self.index = [self.titles count] - 1;
    }
    [self updatePage];
}

- (void) prevPage{
    self.index--;
    if (self.index < 0 ){
        self.index = 0;
    }
    [self updatePage];
}

- (void)updatePage{
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.titleview setFrame:CGRectOffset(titleframe, -self.index*HEADER_LABEL_WIDTH, 0)];
                     }
                     completion:^(BOOL finished){
                         [self.pagecontrol setCurrentPage:self.index];
                     }
     ];
    if (self.delegate){
        [self.delegate updateIndex:self.index AndTitle:self.titles[self.index]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)plusTapped:(id)sender{
    NSLog(@"tap");
}
@end
