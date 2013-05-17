//
//  VLMDrawHeaderController.m
//  Ejecta
//
//  Created by David Lu on 4/28/13.
//
//

#import "VLMDrawHeaderController.h"
#import "DDPageControl.h"
#import "AppDelegate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "VLMActivitySaveToAlbum.h"

#define HEADER_LABEL_WIDTH 175.0f
#define ACTIONSHEET_CLEARSCREEN 1000
#define ACTIONSHEET_SHARE 1001

@interface VLMDrawHeaderController ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIView *titleview;
@property (nonatomic, strong) UIButton *leftbutton;
@property (nonatomic, strong) UIButton *rightbutton;
@property (nonatomic, strong) UIView *cancelbutton;
@property (nonatomic, strong) UIView *titlemask;
@property (nonatomic, strong) UILabel *ghostlabel;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) UIPopoverController *popovercontroller;
@property (nonatomic) NSInteger index;
@property CGRect titleframe;
@property CGRect titlemaskframe;
@property (nonatomic, strong) UIImage *imageToSave;

- (void)setupHeadingView;
- (void)longPress:(id)sender;
- (void)handleCancelPopover:(id)sender;
- (void)togglePopover;
- (void)tapped;

@end

@implementation VLMDrawHeaderController

@synthesize titles;
@synthesize index;
@synthesize titleview;
@synthesize titleframe;
@synthesize titlemask;
@synthesize titlemaskframe;
@synthesize pagecontrol;
@synthesize delegate;
@synthesize leftbutton;
@synthesize rightbutton;
@synthesize isPopoverVisible;
@synthesize cancelbutton;
@synthesize ghostlabel;
@synthesize activityViewController;
@synthesize popovercontroller;
@synthesize imageToSave;

- (id)initWithHeadings:(NSArray *)headings {
    self = [self init];
    if (self) {
        self.index = 0;
        self.titles = [NSArray arrayWithArray:headings];
        self.isPopoverVisible = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.index = 0;
        self.isPopoverVisible = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat HEADER_HEIGHT = 60.0f;
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    
    [self setIndex:0];
    
    [self.view setFrame:CGRectMake(0, 0, winw, HEADER_HEIGHT)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setClipsToBounds:YES];
    
    UIButton *pb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [pb setBackgroundImage:[UIImage imageNamed:@"button_plus_off"] forState:UIControlStateNormal];
    [pb setBackgroundImage:[UIImage imageNamed:@"button_plus_on"] forState:UIControlStateHighlighted];
    [pb addTarget:self action:@selector(plusTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pb];
    [self setLeftbutton:pb];
    
    UIButton *ab = [[UIButton alloc] initWithFrame:CGRectMake(winw - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [ab setBackgroundImage:[UIImage imageNamed:@"button_action_off"] forState:UIControlStateNormal];
    [ab setBackgroundImage:[UIImage imageNamed:@"button_action_on"] forState:UIControlStateHighlighted];
    [ab addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ab];
    [self setRightbutton:ab];
    
    UIView *cancel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winw, HEADER_HEIGHT)];
    [cancel setBackgroundColor:[UIColor whiteColor]];
    [cancel setUserInteractionEnabled:NO];
    [cancel setAlpha:0];
    [self.view addSubview:cancel];
    [self setCancelbutton:cancel];
    
    UITapGestureRecognizer *canceltapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelPopover:)];
    [self.cancelbutton addGestureRecognizer:canceltapped];
    
    UIView *titleviewmask = [[UIView alloc] initWithFrame:CGRectMake(winw / 2 - HEADER_LABEL_WIDTH / 2, 0, HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
    [titleviewmask setClipsToBounds:YES];
    [titleviewmask setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:titleviewmask];
    
    [self setPagecontrol:[[DDPageControl alloc] init]];
    [self.pagecontrol setCenter:CGPointMake(titleviewmask.frame.size.width / 2, HEADER_HEIGHT - 14 + 3)];
    [self.pagecontrol setNumberOfPages:10]; //arbitrary high number so we know something went wrong if this isn't overwritten with the proper number
    [self.pagecontrol setCurrentPage:0];
    [self.pagecontrol setOnColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
    [self.pagecontrol setOffColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [self.pagecontrol setIndicatorDiameter:5.0f];
    [self.pagecontrol setIndicatorSpace:7.0f];
    [self.pagecontrol setUserInteractionEnabled:NO];
    
    [self setTitleframe:CGRectMake(0, 0, 300.0f, HEADER_HEIGHT)];
    [self setTitleview:[[UIView alloc] initWithFrame:self.titleframe]];
    [titleviewmask addSubview:titleview];
    [self.titleview setBackgroundColor:[UIColor clearColor]];
    [self setupHeadingView];
    [self setTitlemask:titleviewmask];
    [self setTitlemaskframe:titleviewmask.frame];
    [titleviewmask addSubview:self.pagecontrol];
    
    self.ghostlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
    [ghostlabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
    [ghostlabel setTextColor:[UIColor blackColor]];
    [ghostlabel setTextAlignment:NSTextAlignmentCenter];
    [ghostlabel setBackgroundColor:[UIColor clearColor]];
    [ghostlabel setAlpha:0.0f];
    [ghostlabel setUserInteractionEnabled:NO];
    [self.titlemask addSubview:ghostlabel];
    
    UISwipeGestureRecognizer *sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextPage)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    [titleviewmask addGestureRecognizer:sgr];
    
    UISwipeGestureRecognizer *sgr2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(prevPage)];
    [sgr2 setDirection:UISwipeGestureRecognizerDirectionRight];
    [titleviewmask addGestureRecognizer:sgr2];
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    [titleviewmask addGestureRecognizer:tgr];
    
    UILongPressGestureRecognizer *lpr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [lpr setNumberOfTapsRequired:0];
    [lpr setNumberOfTouchesRequired:1];
    [titleviewmask addGestureRecognizer:lpr];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    [self.leftbutton addGestureRecognizer:lpgr];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private ()

- (void)setupHeadingView {
    CGFloat HEADER_HEIGHT = 60.0f;
    int count = [self.titles count];
    [self.titleview setFrame:CGRectMake(0, 0, count * HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
    
    NSArray *subViews = self.titleview.subviews;
    for (UIView *aView in subViews) {
        [aView removeFromSuperview];
    }
    
    for (int i = 0; i < count; i++) {
        NSString *t = self.titles[i];
        UILabel *A = [[UILabel alloc] initWithFrame:CGRectMake(i * HEADER_LABEL_WIDTH, 0, HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
        [A setText:t];
        [A setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18.0f]];
        [A setTextColor:[UIColor blackColor]];
        [A setTextAlignment:NSTextAlignmentCenter];
        [A setBackgroundColor:[UIColor clearColor]];
        [self.titleview addSubview:A];
    }
    [self.pagecontrol setNumberOfPages:count];
    [self.pagecontrol setCurrentPage:0];
}

- (void)longPress:(id)sender {
    UILongPressGestureRecognizer *lpr = (UILongPressGestureRecognizer *)sender;
    if (lpr.state == UIGestureRecognizerStateBegan) {
        [self togglePopover];
    }
}

- (void)handleCancelPopover:(id)sender {
    [self togglePopover];
}

- (void)togglePopover {
    self.isPopoverVisible = !self.isPopoverVisible;
    
    if (self.isPopoverVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        [self.cancelbutton setAlpha:0.92];
        [self.cancelbutton setUserInteractionEnabled:YES];
        [UIView commitAnimations];
        
        [self.delegate showPopover];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        [self.cancelbutton setAlpha:0];
        [self.cancelbutton setUserInteractionEnabled:NO];
        [UIView commitAnimations];
        [self.delegate hidePopover];
    }
}

- (void)tapped {
    if (self.ghostlabel.alpha == 1) {
        [self togglePopover];
        return;
    }
    self.index++;
    if (self.index > [self.titles count] - 1) {
        [self setIndex:0];
    }
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.pagecontrol setAlpha:1.0f];
                         [self.titleview setAlpha:1.0f];
                         [self.ghostlabel setAlpha:0.0f];
                     }
     
                     completion:^(BOOL finished) {
                     }
     
     ];
    
    [self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
    [self.pagecontrol setCurrentPage:self.index];
    if (self.delegate) {
        [self.delegate updateIndex:self.index AndTitle:self.titles[self.index]];
    }
}

- (void)swipedDown:(id)sender{
    NSLog(@"swipedown");
}

#pragma mark - public ()

- (void)resetToZero {
    if ([self.titles count] > 0) {
        [self setSelectedIndex:0 andTitle:@"" animated:NO];
        [self updatePage];
    }
}

- (void)setHeadings:(NSArray *)headings {
    [self setTitles:[NSArray arrayWithArray:headings]];
    [self setupHeadingView];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex andTitle:(NSString *)title {
    [self setSelectedIndex:selectedIndex andTitle:title animated:YES];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex andTitle:(NSString *)title animated:(BOOL)shouldAnimate {
    if (selectedIndex != -1) {
        [self setIndex:selectedIndex];
        [self.pagecontrol setCurrentPage:self.index];
        
        if (self.ghostlabel.alpha == 1) {
            [self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
        }
        [UIView animateWithDuration:shouldAnimate ? 0.25f:0
                              delay:0.0f
                            options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if (self.ghostlabel.alpha == 0) {
                                 [self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
                             }
                             [self.pagecontrol setAlpha:1.0f];
                             [self.titleview setAlpha:1.0f];
                             [self.ghostlabel setAlpha:0.0f];
                         }
         
                         completion:^(BOOL finished) {
                         }
         
         ];
    } else {
        [self.ghostlabel setText:title];
        [UIView animateWithDuration:shouldAnimate ? 0.25f:0
                              delay:0.0f
                            options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [self.pagecontrol setAlpha:0.0f];
                             [self.titleview setAlpha:0.0f];
                             [self.ghostlabel setAlpha:1.0f];
                         }
         
                         completion:^(BOOL finished) {
                         }
         
         ];
    }
}

- (void)nextPage {
    [self setIndex:self.index + 1];
    if (self.index > [self.titles count] - 1) {
        self.index = [self.titles count] - 1;
    }
    [self updatePage];
}

- (void)prevPage {
    [self setIndex:self.index - 1];
    if (self.index < 0) {
        [self setIndex:0];
    }
    [self updatePage];
}

- (void)updatePage {
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
                         [self.pagecontrol setAlpha:1.0f];
                         [self.titleview setAlpha:1.0f];
                         [self.ghostlabel setAlpha:0.0f];
                     }
     
                     completion:^(BOOL finished) {
                         [self.pagecontrol setCurrentPage:self.index];
                     }
     
     ];
    if (self.delegate) {
        [self.delegate updateIndex:self.index AndTitle:self.titles[self.index]];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%d", actionSheet.tag);
    if ( actionSheet.tag == ACTIONSHEET_CLEARSCREEN ){
        if (buttonIndex == 0) {
            [self.delegate clearScreen];
        }
    } else {
        if (buttonIndex == 0 && self.imageToSave != nil) {
            ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
            [library saveImage:self.imageToSave toAlbum:@"Vellum" withCompletionBlock:nil];
            //UIImageWriteToSavedPhotosAlbum(self.imageToSave, nil, nil, nil);

            self.imageToSave = nil;
        }
    }
}

#pragma mark - VLMHeaderDelegate

- (void)plusTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start Again", nil];
    [actionSheet setTag:ACTIONSHEET_CLEARSCREEN];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIButton *btn = (UIButton *)sender;
        CGRect c = btn.frame;
        [actionSheet showFromRect:c inView:self.view animated:YES];
    } else {
        [actionSheet showInView:self.view.superview];
    }
}

- (void)actionTapped:(id)sender {
    [self.delegate screenCapture:self];
}

#pragma mark - VLMScreenshotDelegate
- (void)screenShotFound:(UIImage *)found {
    
    // ios6+
    if( NSClassFromString (@"UIActivityViewController") ) {
        NSArray *dataToShare = [NSArray arrayWithObjects:found, @"#madeWithVellum", nil];
        
        VLMActivitySaveToAlbum *activity = [[VLMActivitySaveToAlbum alloc] init];
        NSArray *applicationActivities = @[activity];
        
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:applicationActivities];
        
        [self.activityViewController setExcludedActivityTypes:[NSArray arrayWithObjects:UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, nil]];

        AppDelegate *del = [[UIApplication sharedApplication] delegate];
        UIViewController * mvc = (UIViewController*)del.mainViewController;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.popovercontroller = [[UIPopoverController alloc] initWithContentViewController:self.activityViewController];
            [self.popovercontroller presentPopoverFromRect:self.rightbutton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            
            [mvc presentViewController:self.activityViewController animated:YES completion:^{}];
        }
        return;
    }
    
    // ios5
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", nil];
    [actionSheet setTag:ACTIONSHEET_SHARE];
    self.imageToSave = found;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIButton *btn = self.   
        CGRect c = btn.frame;
        [actionSheet showFromRect:c inView:self.view animated:YES];
    } else {
        [actionSheet showInView:self.view.superview];
    }
    
}

- (UIImage *)screenshotToRestore {
    return nil;
}

@end
