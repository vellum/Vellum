//
//  VLMDrawHeaderController.m
//  Ejecta
//
//  Created by David Lu on 4/28/13.
//
//

#import "VLMDrawHeaderController.h"
#import "AppDelegate.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "VLMActivitySaveToAlbum.h"
#import "VLMMainViewController.h"
#import "VLMConstants.h"
#import "VLMToolCollection.h"
#import "VLMToolData.h"
#import "VLMActivityProvider.h"

#define HEADER_LABEL_WIDTH 175.0f
#define ACTIONSHEET_CLEARSCREEN 1000
#define ACTIONSHEET_SHARE 1001
#define ACTIONSHEET_IMPORT 1002
//#define DESIGN_DEBUG

@interface VLMDrawHeaderController ()

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIView *titleview;
@property (nonatomic, strong) UIButton *leftbutton;
@property (nonatomic, strong) UIButton *rightbutton;
@property (nonatomic, strong) UIView *cancelbutton;
@property (nonatomic, strong) UIView *titlemask;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) UIPopoverController *popovercontroller;
@property (nonatomic) NSInteger index;
@property CGRect titleframe;
@property CGRect titlemaskframe;
@property (nonatomic, strong) UIImage *imageToSave;
@property (nonatomic, strong) UIImagePickerController *pickerController;
@property (nonatomic, strong) UILabel *subtitlelabel;
@property BOOL isPortrait;
@property (nonatomic, strong) UIButton *undobutton;
@property NSInteger undoCount;
@property NSInteger undoIndex;
@property (nonatomic, strong) UIPopoverController *undopop;
@property (nonatomic, strong) UIButton *textbuttonundo;
@property (nonatomic, strong) UIButton *textbuttonredo;
- (void)setupHeadingView;
- (void)longPress:(id)sender;
- (void)handleCancelPopover:(id)sender;
- (void)togglePopover;
- (void)tapped;

- (void)undoLongPressed;
- (void)undoTapped;

@end

@implementation VLMDrawHeaderController

@synthesize titles;
@synthesize index;
@synthesize titleview;
@synthesize titleframe;
@synthesize titlemask;
@synthesize titlemaskframe;
@synthesize delegate;
@synthesize leftbutton;
@synthesize rightbutton;
@synthesize isPopoverVisible;
@synthesize cancelbutton;
@synthesize activityViewController;
@synthesize popovercontroller;
@synthesize imageToSave;
@synthesize pickerController;
@synthesize isPortrait;
@synthesize subtitlelabel;
@synthesize undobutton;
@synthesize undoCount;
@synthesize undoIndex;
@synthesize undopop;
@synthesize textbuttonredo;
@synthesize textbuttonundo;

- (id)initWithHeadings:(NSArray *)headings {
	self = [self init];
	if (self) {
		self.index = 0;
		self.titles = [NSArray arrayWithArray:headings];
		self.isPopoverVisible = NO;
		self.isPortrait = YES;
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.index = 0;
		self.isPopoverVisible = NO;
		self.isPortrait = YES;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	CGFloat winw = [[UIScreen mainScreen] bounds].size.width;
    
	[self setIndex:0];
	[self setIsPortrait:YES];
    
	[self.view setFrame:CGRectMake(0, 0, winw, HEADER_HEIGHT)];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	[self.view setClipsToBounds:YES];
    
	UIButton *pb;
	UIButton *ab;
    UIButton *ub;
    
    pb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
    [pb setBackgroundImage:[UIImage imageNamed:@"button_plus_off"] forState:UIControlStateNormal];
    [pb setBackgroundImage:[UIImage imageNamed:@"button_plus_on"] forState:UIControlStateHighlighted];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        
        ab = [[UIButton alloc] initWithFrame:CGRectMake(winw - HEADER_HEIGHT, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
        [ab setBackgroundImage:[UIImage imageNamed:@"button_action_off"] forState:UIControlStateNormal];
        [ab setBackgroundImage:[UIImage imageNamed:@"button_action_on"] forState:UIControlStateHighlighted];
        
    } else {
        
        /*
        pb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, HEADER_HEIGHT)];
        [pb setBackgroundImage:[UIImage imageNamed:@"button_plus_off_ipad"] forState:UIControlStateNormal];
        [pb setBackgroundImage:[UIImage imageNamed:@"button_plus_on_ipad"] forState:UIControlStateHighlighted];
        */
        
        ub = [[UIButton alloc] initWithFrame:CGRectMake(60, 0, HEADER_HEIGHT, HEADER_HEIGHT)];
        [ub setBackgroundImage:[UIImage imageNamed:@"button_undo_off"] forState:UIControlStateNormal];
        [ub setBackgroundImage:[UIImage imageNamed:@"button_undo_on"] forState:UIControlStateHighlighted];
        [ub setBackgroundImage:[UIImage imageNamed:@"button_undo_on"] forState:UIControlStateDisabled];
    
        [self.view addSubview:ub];
        [self setUndobutton:ub];
        [self.undobutton setEnabled:NO];
        
        [self handleSettingsChange:nil]; // hide or show depending on prefs
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSettingsChange:)
                                                     name:UNDO_SETTING_CHANGED_NOTIFICATION_NAME
                                                   object:nil];
        
        
        UITapGestureRecognizer *utgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(undoTapped)];
        [ub addGestureRecognizer:utgr];

        UILongPressGestureRecognizer *ulpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(undoLongPressed)];
        [ub addGestureRecognizer:ulpgr];
        
        ab = [[UIButton alloc] initWithFrame:CGRectMake(winw - 160, 0, 160, HEADER_HEIGHT)];
        [ab setBackgroundImage:[UIImage imageNamed:@"button_action_off_ipad"] forState:UIControlStateNormal];
        [ab setBackgroundImage:[UIImage imageNamed:@"button_action_on_ipad"] forState:UIControlStateHighlighted];
    }
	[pb addTarget:self action:@selector(plusTapped:) forControlEvents:UIControlEventTouchUpInside];
	[pb setAutoresizingMask:UIViewAutoresizingNone];
	[pb setContentMode:UIViewContentModeTopLeft];
	[self.view addSubview:pb];
	[self setLeftbutton:pb];
    
    
	[ab addTarget:self action:@selector(actionTapped:) forControlEvents:UIControlEventTouchUpInside];
	[ab setAutoresizingMask:UIViewAutoresizingNone | UIViewAutoresizingFlexibleLeftMargin];
	[ab setContentMode:UIViewContentModeTopRight];
	[self.view addSubview:ab];
	[self setRightbutton:ab];
    
	UIView *cancel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winw, HEADER_HEIGHT)];
	[cancel setBackgroundColor:[UIColor whiteColor]];
	[cancel setUserInteractionEnabled:NO];
	[cancel setAlpha:0];
	[cancel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[cancel setContentMode:UIViewContentModeScaleToFill];
	[self.view addSubview:cancel];
	[self setCancelbutton:cancel];
    
	UITapGestureRecognizer *canceltapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleCancelPopover:)];
	[self.cancelbutton addGestureRecognizer:canceltapped];
    
	UIView *titleviewmask = [[UIView alloc] initWithFrame:CGRectMake(winw / 2 - HEADER_LABEL_WIDTH / 2, 0, HEADER_LABEL_WIDTH, HEADER_HEIGHT)];
	[titleviewmask setClipsToBounds:YES];
	[titleviewmask setBackgroundColor:[UIColor clearColor]];
	[titleviewmask setAutoresizingMask:UIViewAutoresizingNone | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
	[titleviewmask setContentMode:UIViewContentModeCenter];
	[self.view addSubview:titleviewmask];
    
    
	[self setTitleframe:CGRectMake(0, 0, 300.0f, HEADER_HEIGHT)];
	[self setTitleview:[[UIView alloc] initWithFrame:self.titleframe]];
	[titleviewmask addSubview:titleview];
	[self.titleview setBackgroundColor:[UIColor clearColor]];
	[self setupHeadingView];
	[self setTitlemask:titleviewmask];
	[self setTitlemaskframe:titleviewmask.frame];
    
	UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
	[titleviewmask addGestureRecognizer:tgr];
    
	UILongPressGestureRecognizer *lpr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
	[lpr setNumberOfTapsRequired:0];
	[lpr setNumberOfTouchesRequired:1];
	[titleviewmask addGestureRecognizer:lpr];
    
    
	UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(plusLongPressed:)];
	[self.leftbutton addGestureRecognizer:lpgr];
    
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self.view setAutoresizesSubviews:YES];
	[self.view setContentMode:UIViewContentModeTop];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)
	                                             name:UIDeviceOrientationDidChangeNotification
	                                           object:nil];
    
#ifdef DESIGN_DEBUG
	UIView *baseline = [[UIView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT / 2.0f, self.view.frame.size.width, 1.0f)];
	baseline.backgroundColor = [UIColor blueColor];
	[baseline setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[baseline setContentMode:UIViewContentModeTop];
	[self.view addSubview:baseline];
#endif
    
	CGFloat labelheight = 24.0f;
	[self setSubtitlelabel:[[UILabel alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT - labelheight, self.titlemask.frame.size.width, labelheight)]];
	[self.subtitlelabel setBackgroundColor:[UIColor clearColor]];
	[self.subtitlelabel setFont:[UIFont fontWithName:@"Georgia-Italic" size:11.0f]];
	[self.subtitlelabel setTextColor:[UIColor colorWithHue:199.0f / 360.0f saturation:0.60f brightness:1.0f alpha:1.0f]];
	[self.subtitlelabel setTextAlignment:NSTextAlignmentCenter];
	[self.subtitlelabel setText:@""];
	[self.subtitlelabel setAlpha:0.0f];
	[self.titlemask addSubview:self.subtitlelabel];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGFloat bighitwidth = HEADER_LABEL_WIDTH * 3;
		UIView *bighitarea = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - bighitwidth) / 2, 0, bighitwidth, HEADER_HEIGHT)];
		[bighitarea setBackgroundColor:[UIColor clearColor]];
		[bighitarea setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[bighitarea addGestureRecognizer:tgr];
		[bighitarea addGestureRecognizer:lpr];
		[self.view addSubview:bighitarea];
	} else {

		CGFloat bighitwidth = winw - 60*2;
		UIView *bighitarea = [[UIView alloc] initWithFrame:CGRectMake(60, 0, bighitwidth, HEADER_HEIGHT)];
		[bighitarea setBackgroundColor:[UIColor clearColor]];
		[bighitarea setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[bighitarea addGestureRecognizer:tgr];
		[bighitarea addGestureRecognizer:lpr];
		[self.view addSubview:bighitarea];
        
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - private ()

- (void)setupHeadingView {
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
		[A setUserInteractionEnabled:NO];
		[self.titleview addSubview:A];
	}
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

- (void)tapped {
	[self togglePopover];
	return;
    
	self.index++;
	if (self.index > [self.titles count] - 1) {
		[self setIndex:0];
	}
	[UIView animateWithDuration:ANIMATION_DURATION
	                      delay:0.0f
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [self.titleview setAlpha:1.0f];
                     }
     
	                 completion: ^(BOOL finished) {
                     }
     
     ];
    
	[self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
	if (self.delegate) {
		[self.delegate updateIndex:self.index AndTitle:self.titles[self.index]];
	}
}

- (void)plusLongPressed:(id)sender {
	UILongPressGestureRecognizer *lpgr = (UILongPressGestureRecognizer *)sender;
	if ([lpgr state] == UIGestureRecognizerStateBegan) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Image", nil];
		[actionSheet setTag:ACTIONSHEET_IMPORT];
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			CGRect c = CGRectMake(self.leftbutton.frame.origin.x, self.leftbutton.frame.origin.y, HEADER_HEIGHT, HEADER_HEIGHT);
			[actionSheet showFromRect:c inView:self.view animated:YES];
		}
		else {
			[actionSheet showInView:self.view.superview];
		}
	}
}

- (void)undoLongPressed{
    [self undoTapped];
}

- (void)undoTapped{
    if ( !self.undopop ){
        CGSize m = CGSizeMake(160, 100);
        
        UIViewController *vc = [[UIViewController alloc] init];
        [vc setContentSizeForViewInPopover:m];
        [vc.view setBackgroundColor:[UIColor whiteColor]];
        [vc.view setAutoresizesSubviews:NO];
        
        UIButton *tbundo = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, m.width, m.height/2)];
        [tbundo setBackgroundColor:[UIColor whiteColor]];
        [tbundo setTitle:@"Undo" forState:UIControlStateNormal];
        [tbundo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tbundo setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [tbundo setBackgroundImage:[UIImage imageNamed:@"clear10"] forState:UIControlStateHighlighted];
        [tbundo setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateDisabled];
        [tbundo.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
        [vc.view addSubview:tbundo];
        [self setTextbuttonundo:tbundo];
        if (self.undoIndex>0){
            ////NSLog(@"enable undo");
            [tbundo setEnabled:YES];
        } else {
            ////NSLog(@"disable undo");
            [tbundo setEnabled:NO];
        }
        UITapGestureRecognizer *tbtgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textUndoTapped)];
        [tbundo addGestureRecognizer:tbtgr];
        
        UIButton *tbredo = [[UIButton alloc] initWithFrame:CGRectMake(0, m.height/2, m.width, m.height/2)];
        [tbredo setBackgroundColor:[UIColor whiteColor]];
        [tbredo setTitle:@"Redo" forState:UIControlStateNormal];
        [tbredo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tbredo setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [tbredo setBackgroundImage:[UIImage imageNamed:@"clear10"] forState:UIControlStateHighlighted];
        [tbredo setTitleColor:[UIColor colorWithWhite:0.9f alpha:1.0f] forState:UIControlStateDisabled];
        [tbredo.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
        [vc.view addSubview:tbredo];
        [self setTextbuttonredo:tbredo];
        
        if (self.undoIndex >= self.undoCount-1){
            ////NSLog(@"disable redo");
            [tbredo setEnabled:NO];
        } else {
            ////NSLog(@"enable redo");
            [tbredo setEnabled:YES];
        }
        UITapGestureRecognizer *tbtgr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textRedoTapped)];
        [tbredo addGestureRecognizer:tbtgr2];
        
        UIPopoverController *upop = [[UIPopoverController alloc] initWithContentViewController:vc];
        [self setUndopop:upop];
    }
    [self.undopop presentPopoverFromRect:self.undobutton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];}

- (void)textUndoTapped{
    [self.delegate requestUndo];
}

- (void)textRedoTapped{
    [self.delegate requestRedo];
}

- (void)handleSettingsChange:(NSNotification *)notification{
    NSLog(@"notification!");
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) return;
        
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    VLMSettingsData *data = delegate.settings;
    if (data.undoEnabled) {
        [self.undobutton setEnabled:YES];
        [self.undobutton setAlpha:1.0f];
    } else {
        [self.undobutton setEnabled:NO];
        [self.undobutton setAlpha:0.0f];
    }
    
}

#pragma mark - public ()
- (void)togglePopover {
	self.isPopoverVisible = !self.isPopoverVisible;
    
	if (self.isPopoverVisible) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:ANIMATION_DURATION];
		[self.cancelbutton setAlpha:0.92];
		[self.cancelbutton setUserInteractionEnabled:YES];
		[UIView commitAnimations];
        
		[self.delegate showPopover];
	}
	else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:ANIMATION_DURATION];
		[self.cancelbutton setAlpha:0];
		[self.cancelbutton setUserInteractionEnabled:NO];
		[UIView commitAnimations];
		[self.delegate hidePopover];
	}
}

- (void)showPopover {
	self.isPopoverVisible = YES;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:ANIMATION_DURATION];
	[self.cancelbutton setAlpha:0.92];
	[self.cancelbutton setUserInteractionEnabled:YES];
	[UIView commitAnimations];
    
	[self.delegate showPopover];
}

- (void)resetToZero {
	if ([self.titles count] > 0) {
		[self setSelectedIndex:0 andTitle:@"" animated:NO];
		[self updatePage];
	}
	else {
		VLMToolCollection *tools = [VLMToolCollection instance];
		VLMToolData *data = [tools.tools objectAtIndex:0];
		[data setSelected:YES];
		[tools setSelectedIndex:0];
		[self setSelectedIndex:-1 andTitle:data.name];
		if (self.delegate) {
			[self.delegate updateIndex:0 AndTitle:data.name];
		}
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
        
		[UIView animateWithDuration:shouldAnimate ? ANIMATION_DURATION * 2:0
		                      delay:0.0f
		                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
		                 animations: ^{
                             [self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
                             [self.titleview setAlpha:1.0f];
                         }
         
		                 completion: ^(BOOL finished) {
                         }
         
         ];
	}
	else {
		[UIView animateWithDuration:shouldAnimate ? ANIMATION_DURATION * 2:0
		                      delay:0.0f
		                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
		                 animations: ^{
                             [self.titleview setAlpha:0.0f];
                         }
         
		                 completion: ^(BOOL finished) {
                         }
         
         ];
	}
}

- (void)showSubtitleWithText:(NSString *)text {
	[self.subtitlelabel setText:text];
	[UIView animateWithDuration:ANIMATION_DURATION * 2
	                      delay:0.0f
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [self.subtitlelabel setAlpha:1.0f];
                     }
     
	                 completion: ^(BOOL finished) {
                     }
     
     ];
}

- (void)hideSubtitle {
	[UIView animateWithDuration:ANIMATION_DURATION * 2
	                      delay:0.0f
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [self.subtitlelabel setAlpha:0.0f];
                     }
     
	                 completion: ^(BOOL finished) {
                     }
     
     ];
}

- (void)nextPage {
	if (![[VLMToolCollection instance] isToggleable]) return;
	[self setIndex:self.index + 1];
	if (self.index > [self.titles count] - 1) {
		self.index = [self.titles count] - 1;
	}
	[self updatePage];
}

- (void)prevPage {
	if (![[VLMToolCollection instance] isToggleable]) return;
	[self setIndex:self.index - 1];
	if (self.index < 0) {
		[self setIndex:0];
	}
	[self updatePage];
}

- (void)updatePage {
	[UIView animateWithDuration:ANIMATION_DURATION * 2
	                      delay:0.0f
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [self.titleview setFrame:CGRectOffset(titleframe, -self.index * HEADER_LABEL_WIDTH, 0)];
                         [self.titleview setAlpha:1.0f];
                     }
     
	                 completion: ^(BOOL finished) {
                     }
     
     ];
	if (self.delegate) {
		[self.delegate updateIndex:self.index AndTitle:self.titles[self.index]];
	}
}

- (void)dismissPopoverController {
	if (self.popovercontroller != nil) {
		[self.popovercontroller dismissPopoverAnimated:YES];
	}
}

- (void)cleanupImagePicker {
	if (self.popovercontroller != nil) {
		[self setPopovercontroller:nil];
	}
	if (self.pickerController != nil) {
		[self setPickerController:nil];
	}
}

#pragma mark - UIActionSheetDelegate
// FIXME: in ios7-ipad, the status bar appears when imagepicker is opened (seemingly not controllable)
// and needs to be explicitly removed when:
// - cancelling the popover (not sure if handled)
// - selecting an image (handled)

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	//////NSLog(@"%d", actionSheet.tag);
	switch (actionSheet.tag) {
		case ACTIONSHEET_CLEARSCREEN :
			if (buttonIndex == 0) {
				[self.delegate clearScreen];
			}
			break;
            
		case ACTIONSHEET_IMPORT :
			if (buttonIndex == 0) {
				AppDelegate *del = [[UIApplication sharedApplication] delegate];
				VLMMainViewController *mvc = (VLMMainViewController *)del.mainViewController;
				UIImagePickerController *picker = [[UIImagePickerController alloc] init];
				[picker setDelegate:mvc];
				[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [picker setContentSizeForViewInPopover:CGSizeMake(320.0f, 568.0f)];
				self.pickerController = picker;
                
				if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
					self.popovercontroller = [[UIPopoverController alloc] initWithContentViewController:picker]; // does this need to be a property?
                    [self.popovercontroller setDelegate:self];
                    
					[self.popovercontroller presentPopoverFromRect:CGRectMake(self.leftbutton.frame.origin.x, self.leftbutton.frame.origin.y, HEADER_HEIGHT, HEADER_HEIGHT) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
				else {
#if FAT_HEADER
					[picker.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
#endif
					UIViewController *vc = (UIViewController *)mvc;
					[vc presentViewController:picker animated:YES completion: ^{}];
                     
				}
			}
            
		case ACTIONSHEET_SHARE:
			if (buttonIndex == 0 && self.imageToSave != nil) {
				ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
				[library saveImage:self.imageToSave toAlbum:@"Vellum" withCompletionBlock:nil];
				self.imageToSave = nil;
			}
			break;
            
		default:
			break;
	}
}

#pragma mark - VLMHeaderDelegate

- (void)plusTapped:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start Again", nil];
	[actionSheet setTag:ACTIONSHEET_CLEARSCREEN];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGRect c = CGRectMake(self.leftbutton.frame.origin.x, self.leftbutton.frame.origin.y, HEADER_HEIGHT, HEADER_HEIGHT);
		[actionSheet showFromRect:c inView:self.view animated:YES];
	}
	else {
		[actionSheet showInView:self.view.superview];
	}
}

- (void)actionTapped:(id)sender {
	[self.delegate screenCapture:self];
}

#pragma mark - VLMScreenshotDelegate
- (void)screenShotFound:(UIImage *)found {
    CGRect c = CGRectMake(self.rightbutton.frame.origin.x + self.rightbutton.frame.size.width - HEADER_HEIGHT, self.rightbutton.frame.origin.y, HEADER_HEIGHT, HEADER_HEIGHT);

	// ios6+
	if (NSClassFromString(@"UIActivityViewController")) {
		VLMActivityProvider *activityProvider = [[VLMActivityProvider alloc] init];
		NSArray *dataToShare = @[found, activityProvider];
        
		VLMActivitySaveToAlbum *activity = [[VLMActivitySaveToAlbum alloc] init];
		NSArray *applicationActivities = @[activity];
        
		self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:applicationActivities];
        
		[self.activityViewController setExcludedActivityTypes:@[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeMessage]];
        
		AppDelegate *del = [[UIApplication sharedApplication] delegate];
		UIViewController *mvc = (UIViewController *)del.mainViewController;
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			self.popovercontroller = [[UIPopoverController alloc] initWithContentViewController:self.activityViewController];
			[self.popovercontroller presentPopoverFromRect:c inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
		else {
			[mvc presentViewController:self.activityViewController animated:YES completion: ^{}];
		}
		return;
	}
    
	// ios5
    
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", nil];
	[actionSheet setTag:ACTIONSHEET_SHARE];
	self.imageToSave = found;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[actionSheet showFromRect:c inView:self.view animated:YES];
	}
	else {
		[actionSheet showInView:self.view.superview];
	}
}

- (UIImage *)screenshotToRestore {
	return nil;
}

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    AppDelegate *del = [[UIApplication sharedApplication] delegate];
    VLMMainViewController *mvc = (VLMMainViewController *)del.mainViewController;
    [mvc hideStatusBarIfNeeded];
}

#pragma mark - rotation
// FIXME: shouldn't be trapping for nonaliased orientation values. proper way to do this is with UIDeviceOrientationPortrait, UIDeviceOrientation PortraitUpsideDown, etc
- (void)didRotate:(NSNotification *)notification {
	//////NSLog(@"here: rotation detected in header");
    
	BOOL isNowPortrait = self.isPortrait;
	int type = [[UIDevice currentDevice] orientation];
	if (type == 1) {
		isNowPortrait = YES;
	}
	else if (type == 2) {
		isNowPortrait = YES;
	}
	else if (type == 3) {
		isNowPortrait = NO;
	}
	else if (type == 4) {
		isNowPortrait = NO;
	}
	if (isNowPortrait == self.isPortrait) return;
    
	[self setIsPortrait:isNowPortrait];
    
	if (self.popovercontroller && [self.popovercontroller isPopoverVisible]) {
		[self.popovercontroller dismissPopoverAnimated:YES];
	}
}


#pragma mark - ()
- (void)updateUndoIndex:(NSInteger)undoIndexIn andUndoCount:(NSInteger)undoCountIn{
    
    ////NSLog(@"here %i %i", undoIndexIn, undoCountIn);
    if (!self.undobutton) return;
    [self setUndoCount:undoCountIn];
    [self setUndoIndex:undoIndexIn];
    if ( undoCountIn <= 1 ){
        [self.undobutton setEnabled:NO];
    } else {
        [self.undobutton setEnabled:YES];
    }
    if ( self.textbuttonundo){
        if (self.undoIndex>0){
            ////NSLog(@"enable undo");
            [self.textbuttonundo setEnabled:YES];
        } else {
            ////NSLog(@"disable undo");
            [self.textbuttonundo setEnabled:NO];
        }
    }
    if ( self.textbuttonredo){
        if (self.undoIndex >= self.undoCount-1){
            ////NSLog(@"disable redo");
            [self.textbuttonredo setEnabled:NO];
        } else {
            ////NSLog(@"enable redo");
            [self.textbuttonredo setEnabled:YES];
        }
    }
}
@end
