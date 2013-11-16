//
//  VLMMainViewController.m
//  Ejecta
//
//  Created by David Lu on 4/21/13.
//
//
#import "UIColor+Components.h"
#import "VLMMainViewController.h"
#import "VLMDrawHeaderController.h"
#import "VLMZoomViewController.h"
#import "VLMPanGestureRecognizer.h"
#import "VLMPinchGestureRecognizer.h"
#import "VLMSinglePanGestureRecognizer.h"
#import "VLMTwoFingerTapGestureRecognizer.h"
#import "EJAppViewController.h"
#import "VLMTapGestureRecognizer.h"
#import "VLMPopMenuViewController.h"
#import "VLMToolCollection.h"
#import "VLMToolData.h"
#import "DDPageControl.h"
#import "VLMUndoState.h"
#import "VLMUndoViewController.h"
#import "VLMConstants.h"
#import "UINavigationBar+Fat.h"
#import "VLMColorMenuViewController.h"
#import "VLMColorData.h"
#import "Flurry.h"
#import "AppDelegate.h"
#import "SmoothStroke.h"
#import "AbstractBezierPathElement.h"
#import "LineToPathElement.h"
#import "CurveToPathElement.h"

#define FLURRY_TOOLS_OPEN @"ToolMenuVisible"
#define FLURRY_TOOLS_CLOSED @"ToolMenuHidden"
#define FLURRY_COLORS_OPEN @"ColorMenuVisible"
#define FLURRY_COLORS_CLOSED @"ColorMenuHidden"
#define FLURRY_PATH_MENU @"Menu"
#define FLURRY_CLEAR @"ClearScreen"
//#define USE_INCREMENTAL_SAVE 1

@interface VLMMainViewController ()

@property (strong,nonatomic) SmoothStroke* curStroke;
@property (strong, nonatomic) VLMDrawHeaderController *headerController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;
@property (strong, nonatomic) VLMUndoViewController *undoViewController;
@property (strong, nonatomic) EJAppViewController *avc;
@property (strong, nonatomic) VLMPopMenuViewController *pop;
@property CGFloat pinchLastScale;
@property CGPoint pinchLastPoint;
@property CGFloat pinchAccumulatedScale;
@property (strong, nonatomic) UIImage *restoreUndoImage;
@property NSInteger lastKnownUndoIndex;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (assign, nonatomic) UIPopoverController *rightPopover;
@property BOOL firstTime;
@property BOOL isPortrait;
@property BOOL didJustWake;
@property (strong, nonatomic) VLMColorMenuViewController *colorMenuViewController;
@property BOOL previouslyCleared;
@property BOOL previouslySelectedTool;
@property BOOL shouldSaveInBackground;
@property BOOL shouldRemoveExistingFile;
@property CGFloat travelDistance;
@property CGPoint previousTouchLocation;
@property CGPoint previousTouchLocationTransformed;
@property CGFloat curPressure;

- (void)handleOneFingerPan:(id)sender;
- (void)handleTwoFingerPan:(id)sender;
- (void)handleThreeFingerPan:(id)sender;
- (void)handlePinch:(id)sender;
- (void)handleSingleTap:(id)sender;
- (void)handleDoubleTap:(id)sender;
- (void)enteredForeground;

@end

@implementation VLMMainViewController

@synthesize headerController;
@synthesize touchCaptureView;
@synthesize zoomViewController;
@synthesize undoViewController;
@synthesize avc;
@synthesize undoManager;
@synthesize pinchLastScale;
@synthesize pinchLastPoint;
@synthesize pinchAccumulatedScale;
@synthesize restoreUndoImage;
@synthesize lastKnownUndoIndex;
@synthesize infoButton;
@synthesize flipsidePopoverController;
@synthesize firstTime;
@synthesize rightPopover;
@synthesize isPortrait;
@synthesize colorMenuViewController;
@synthesize didJustWake;
@synthesize previouslyCleared;
@synthesize previouslySelectedTool;
@synthesize shouldSaveInBackground;
@synthesize shouldRemoveExistingFile;
@synthesize curStroke;
@synthesize travelDistance;
@synthesize previousTouchLocation;
@synthesize previousTouchLocationTransformed;
@synthesize curPressure;
    
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		firstTime = YES;
	}
	return self;
}

- (id)initWithEJAppViewController:(EJAppViewController *)appViewController {
	self = [super init];
	if (self) {
		firstTime = YES;
		[self setAvc:appViewController];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [self setShouldSaveInBackground:NO];
	[self setPreviouslyCleared:NO];
	[self setPreviouslySelectedTool:NO];
    [self setShouldRemoveExistingFile:NO];
	[self setIsPortrait:YES];
	CGRect frame = UIScreen.mainScreen.bounds;
	UIView *t = [[UIView alloc] initWithFrame:frame];
	[self setDidJustWake:NO];
	[t setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	//EJAppViewController *vc = [[EJAppViewController alloc] init];
	VLMZoomViewController *z = [[VLMZoomViewController alloc] init];
	VLMUndoViewController *uvc = [[VLMUndoViewController alloc] init];
    
	VLMDrawHeaderController *h = [[VLMDrawHeaderController alloc] init];
	[h setDelegate:self];
    
	UIButton *ib = [UIButton buttonWithType:UIButtonTypeInfoDark];
	//[ib setBackgroundColor:[UIColor redColor]];
	CGFloat margin = 15;
	[ib setFrame:CGRectMake(ib.frame.origin.x - margin, ib.frame.origin.y - margin,
	                        ib.frame.size.width + margin * 2, ib.frame.size.height + margin * 2)];
    
	[ib setFrame:CGRectMake(frame.size.width - ib.frame.size.width, frame.size.height - ib.frame.size.height, ib.frame.size.width, ib.frame.size.height)];
	[ib addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[ib setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    
	[self setPinchLastScale:1.0f];
	[self setPinchAccumulatedScale:1.0f];
    
	[self.view setFrame:frame];
	//[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
	[self.view setBackgroundColor:[UIColor clearColor]];
	//[self.view addSubview:vc.view];
	[self.view addSubview:z.view];
	[self.view addSubview:uvc.view];
	[self.view addSubview:t];
	[self.view addSubview:h.view];
	[self.view addSubview:ib];
    
	//[self setAvc:vc];
	[self setZoomViewController:z];
	[self setTouchCaptureView:t];
	[self setHeaderController:h];
	[self setUndoViewController:uvc];
	[self setInfoButton:ib];
    
	VLMPanGestureRecognizer *twoFingerPan = [[VLMPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
	[twoFingerPan setMinimumNumberOfTouches:2];
	[twoFingerPan setMaximumNumberOfTouches:2];
	[twoFingerPan setDelegate:self];
    
	VLMSinglePanGestureRecognizer *oneFingerPan = [[VLMSinglePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
	[oneFingerPan setDelegate:self];
    
	VLMPanGestureRecognizer *threeFingerPan = [[VLMPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreeFingerPan:)];
	[threeFingerPan setMinimumNumberOfTouches:3];
	[threeFingerPan setMaximumNumberOfTouches:3];
	[threeFingerPan setDelegate:self];
    
	VLMPinchGestureRecognizer *pinch = [[VLMPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	[pinch setDelegate:self];
    
	VLMTapGestureRecognizer *doubleTap = [[VLMTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	[doubleTap setNumberOfTapsRequired:2];
	[doubleTap setDelegate:self];
    
	VLMTapGestureRecognizer *singleTap = [[VLMTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[singleTap setNumberOfTapsRequired:1];
	[singleTap setCancelsTouchesInView:NO];
	//[singleTap requireGestureRecognizerToFail:doubleTap];
	[singleTap setDelegate:self];
    
	VLMTwoFingerTapGestureRecognizer *twoFingerSingleTap = [[VLMTwoFingerTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerSingleTap:)];
	[twoFingerSingleTap setCancelsTouchesInView:NO];
	[twoFingerSingleTap setDelegate:self];
	[twoFingerSingleTap requireGestureRecognizerToFail:pinch];
	[twoFingerSingleTap requireGestureRecognizerToFail:twoFingerPan];
    
	[t addGestureRecognizer:pinch];
	[t addGestureRecognizer:twoFingerPan];
	[t addGestureRecognizer:oneFingerPan];
	[t addGestureRecognizer:doubleTap];
	[t addGestureRecognizer:singleTap];
	[t addGestureRecognizer:twoFingerSingleTap];
    
	// only enable 3 finger undo for small screen devices
	// to counter glreadpixels performance problems
	//if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    //if ([AppDelegate isUndoCapable]){
		[t addGestureRecognizer:threeFingerPan];
	//}
    
	VLMPopMenuViewController *poppy = [[VLMPopMenuViewController alloc] init];
	[poppy setDelegate:self];
	[self.view addSubview:poppy.view];
	[self setPop:poppy];
    
    
	VLMColorMenuViewController *colory = [[VLMColorMenuViewController alloc] init];
	[colory setDelegate:self];
	[self.view addSubview:colory.view];
	[self setColorMenuViewController:colory];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(enteredForeground)
	                                             name:UIApplicationDidBecomeActiveNotification
	                                           object:nil];
    
	[self.headerController updatePage];
    
	lastKnownUndoIndex = 0;
    
	[self refreshData];
	[self updateHeader];
	VLMToolCollection *toolcollection = [VLMToolCollection instance];
	VLMToolData *selecteditem = (VLMToolData *)[toolcollection.tools objectAtIndex:toolcollection.selectedIndex];
	if (!selecteditem.enabled) {
		[h setSelectedIndex:-1 andTitle:selecteditem.name animated:NO];
	}
	[self handleDoubleTap:nil];
    
	///*
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:)
	                                             name:UIDeviceOrientationDidChangeNotification
	                                           object:nil];
	//*/
    
	[Flurry logEvent:FLURRY_TOOLS_CLOSED timed:YES];
	[Flurry logEvent:FLURRY_COLORS_CLOSED timed:YES];
	[Flurry logEvent:FLURRY_CLEAR timed:YES];
    
    [self loadExistingDrawing];
}

#pragma mark -
// TODO: handle memory warning

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecco Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
		UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)otherGestureRecognizer;
		if (pgr.minimumNumberOfTouches == 3) return NO;
	}
	return YES;
}

#pragma mark - ()

- (void)handleOneFingerPan:(id)sender {
	VLMSinglePanGestureRecognizer *pgr = (VLMSinglePanGestureRecognizer *)sender;
	CGPoint p = [pgr locationInView:self.avc.view];
	p.x += 1 / self.zoomViewController.zoomlevel * JOT_X_OFFSET;
	p.y += 1 / self.zoomViewController.zoomlevel * JOT_Y_OFFSET;
    
    
    VLMToolCollection *tools = [VLMToolCollection instance];
	VLMToolData *selectedtool = (VLMToolData *)[tools getSelectedToolFromEnabledIndex:tools.selectedIndex];
    BOOL isBezierRequired = selectedtool.isBezierRequired;
        
	if ([pgr state] == UIGestureRecognizerStateBegan) {
        [self setTravelDistance:0];
        [self setPreviousTouchLocation:[pgr locationInView:self.view]];

		NSString *s = [NSString stringWithFormat:@"beginStroke(%f,%f);", p.x, p.y];
		[self.avc callJS:s];
		s = [NSString stringWithFormat:@"setZoom( %f );", self.zoomViewController.zoomlevel];
		[self.avc callJS:s];
        CGFloat strokeWidth = 0;
        
        if ( isBezierRequired ){
            self.curStroke = [[SmoothStroke alloc] init];
            [self setCurPressure:strokeWidth];
            [self addLineToAndRenderStroke:self.curStroke toPoint:p toWidth:strokeWidth toColor:[UIColor blackColor]];
            [self setPreviousTouchLocationTransformed:[pgr locationInView:self.avc.view]];
        }
		return;
	}
	else if ([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
		NSString *s = [NSString stringWithFormat:@"endStroke(%f,%f);", p.x, p.y];
		[self.avc callJS:s];
        
        
        // EXPERIMENTAL FEATURE - may cause perf problems outside of iphone 5
        [self saveStateInBackground];
		return;
	}

    if (isBezierRequired){
        CGPoint cur = [pgr locationInView:self.view];
        CGPoint prev = self.previousTouchLocation;
        CGFloat dx = cur.x-prev.x;
        CGFloat dy = cur.y-prev.y;
        CGFloat dist = sqrt(dx*dx+dy*dy);

        
        CGPoint curtransformed = [pgr locationInView:self.avc.view];
        CGPoint prevX = self.previousTouchLocationTransformed;
        CGFloat dxX = curtransformed.x-prevX.x;
        CGFloat dyX = curtransformed.y-prevX.y;
        CGFloat distX = sqrt(dxX*dxX+dyX*dyX);
        [self setPreviousTouchLocationTransformed:curtransformed];

        CGFloat strokeWidth = self.curPressure + (distX - self.curPressure ) * 0.25f;
        [self setCurPressure:strokeWidth];

        
        [self setPreviousTouchLocation:cur];
        [self setTravelDistance:self.travelDistance + dist];
        [self addLineToAndRenderStroke:self.curStroke toPoint:p toWidth:strokeWidth toColor:[UIColor blackColor]];
        
    } else {
        NSString *s = [NSString stringWithFormat:@"continueStroke(%f,%f);", p.x, p.y];
        [self.avc callJS:s];
    }
}

- (void)handleTwoFingerPan:(id)sender {
	VLMPanGestureRecognizer *pgr = (VLMPanGestureRecognizer *)sender;
	if (pgr.numberOfTouches != 2) {
		return;
	}
	else if ([pgr state] == UIGestureRecognizerStateBegan) {
		return;
	}
	else if ([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
		return;
	}
	UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
	CGPoint p = [(UIPanGestureRecognizer *)sender translationInView : window]; //self.touchCaptureView];
	[sender setTranslation:CGPointZero inView:window]; //self.touchCaptureView];
	CGPoint c = self.avc.view.center;
	c.x += p.x; c.y += p.y;
	[self.avc.view setCenter:c];
}

- (void)handleThreeFingerPan:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    VLMSettingsData *data = delegate.settings;
    if (!data.undoEnabled) return;
    
    
	VLMPanGestureRecognizer *pgr = (VLMPanGestureRecognizer *)sender;
	switch ([pgr state]) {
		case UIGestureRecognizerStateBegan:
		case UIGestureRecognizerStateChanged:
			if (![self.undoViewController isVisible]) {
				[self.undoViewController show];
				lastKnownUndoIndex = self.undoViewController.index;
			}
			break;
            
		default:
			if ([self.undoViewController isVisible]) {
				[self.undoViewController hide];
			}
			break;
	}
	if (pgr.numberOfTouches != 3) return;
	CGPoint xy = [pgr translationInView:pgr.view];
	CGFloat delta = xy.y;
	CGFloat interval = 240.0f / 8.0f;
	delta = floorf(delta / interval);
    
	NSInteger nextIndex = lastKnownUndoIndex + delta;
	if (nextIndex < 0) nextIndex = 0;
	if (nextIndex > self.undoViewController.numStates - 1) nextIndex = self.undoViewController.numStates - 1;
    
	if (nextIndex != self.undoViewController.index) {
		////NSLog(@"nextIndex: %d", nextIndex);
		NSString *s = [NSString stringWithFormat:@"restoreUndoStateAtIndex(%d);", nextIndex];
		[self.avc callJS:s];
	}
}

- (void)handlePinch:(id)sender {
    
    [self.avc callJS: @"delayQueuedSave();"];
    
    
	VLMPinchGestureRecognizer *pgr = (VLMPinchGestureRecognizer *)sender;
	int numberOfTouches = pgr.numberOfTouches;
    
	UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
	CGRect bounds = window.frame;
	//CGRect bounds = [[UIScreen mainScreen] bounds];
    
	if ([pgr state] == UIGestureRecognizerStateBegan) {
		CGPoint location = [sender locationInView:self.avc.view];
		if (!self.avc.shouldDoubleResolution) {
			[self setPinchLastPoint:CGPointMake(location.x / bounds.size.width, location.y / bounds.size.height)]; // this is now a percentage value
		}
		else {
			// 3gs & non-retina ipads gets this
			[self setPinchLastPoint:CGPointMake(location.x / (bounds.size.width * OLD_DEVICE_SCREEN_MULTIPLIER), location.y / (bounds.size.height * OLD_DEVICE_SCREEN_MULTIPLIER))]; // this is now a percentage value
		}
		[self setPinchLastScale:1.0f];
		[self.zoomViewController show];
		return;
	}
	else if ([pgr state] == UIGestureRecognizerStateEnded) {
		[self.zoomViewController hide];
		return;
	}
    
	if (numberOfTouches == 1) {
		[zoomViewController hide];
		return;
	}
    
	if (numberOfTouches >= 3) {
		[zoomViewController hide];
		return;
	}
    
	if (![zoomViewController isVisible]) {
		[zoomViewController show];
	}
    
	CGFloat scale = 1.0 - (self.pinchLastScale - [(UIPinchGestureRecognizer *)sender scale]);
	[self setPinchLastScale:[(UIPinchGestureRecognizer *)sender scale]];
    
	CGFloat accum = self.pinchAccumulatedScale * scale;
	if (accum < 0.25) accum = 0.25;
	if (accum > 40) accum = 40;
	[self setPinchAccumulatedScale:accum];
    
	if (!self.avc.shouldDoubleResolution) {
		bounds.size.width *= self.pinchAccumulatedScale;
		bounds.size.height *= self.pinchAccumulatedScale;
        
		CGPoint xy = [sender locationInView:window];
		CGPoint topleft = CGPointMake(xy.x - self.pinchLastPoint.x * bounds.size.width, xy.y - self.pinchLastPoint.y * bounds.size.height);
		bounds.origin = topleft;
		[self.avc.view setTransform:CGAffineTransformMakeScale(self.pinchAccumulatedScale, self.pinchAccumulatedScale)];
		[self.avc.view setCenter:CGPointMake(topleft.x + bounds.size.width / 2, topleft.y + bounds.size.height / 2)];
	}
	else {
		CGFloat w = (bounds.size.width * OLD_DEVICE_SCREEN_MULTIPLIER) * self.pinchAccumulatedScale;
		CGFloat h = (bounds.size.height * OLD_DEVICE_SCREEN_MULTIPLIER) * self.pinchAccumulatedScale;
        
		CGPoint xy = [sender locationInView:window];
		CGPoint topleft = CGPointMake(xy.x - self.pinchLastPoint.x * w, xy.y - self.pinchLastPoint.y * h);
		bounds.origin = topleft;
		[self.avc.view setTransform:CGAffineTransformMakeScale(self.pinchAccumulatedScale, self.pinchAccumulatedScale)];
		[self.avc.view setCenter:CGPointMake(topleft.x + w / 2, topleft.y + h / 2)];
	}
    
	int val = round(self.pinchAccumulatedScale * 100);
	[zoomViewController setText:val];
}

- (void)handleSingleTap:(id)sender {
	//if (self.headerController.isPopoverVisible) return;
    
	VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
	if (tgr.numberOfTouches > 1) return;
    
	UIView *h = self.headerController.view;
	[h setUserInteractionEnabled:!h.userInteractionEnabled];
	[self.infoButton setUserInteractionEnabled:h.userInteractionEnabled];
	if (self.headerController.isPopoverVisible) {
		if (h.userInteractionEnabled) {
			[self.pop show];
		}
		else {
			[self.pop hide];
		}
	}
	if ([self.colorMenuViewController isOpen]) {
		[self.colorMenuViewController singleTapToggle];
		//[self.colorMenuViewController hide];
	}
    
	[UIView animateWithDuration:0.25f
	                      delay:0.0f
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [h setAlpha:(h.userInteractionEnabled) ? 1:0];
                         [self.infoButton setAlpha:(h.userInteractionEnabled) ? 1:0];
                     }
     
	                 completion: ^(BOOL finished) {
                         [self.infoButton setUserInteractionEnabled:(self.infoButton.alpha == 1)];
                     }
     
     ];
}

- (void)handleDoubleTap:(id)sender {
	VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
	if (tgr.numberOfTouches > 1) return;
    
	if (!self.avc.shouldDoubleResolution) {
		[self.zoomViewController setText:100];
		self.pinchAccumulatedScale = 1.0f;
		CGRect bounds = [[UIScreen mainScreen] bounds];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.2];
		[self.avc.view setTransform:CGAffineTransformMakeScale(1, 1)];
		[self.avc.view setCenter:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)];
		[UIView commitAnimations];
	}
	else {
		[self.zoomViewController setText:round(1.0f / OLD_DEVICE_SCREEN_MULTIPLIER * 100.0f)];
		self.pinchAccumulatedScale = 1.0f / OLD_DEVICE_SCREEN_MULTIPLIER;
		CGRect bounds = [[UIScreen mainScreen] bounds];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.2];
		[self.avc.view setTransform:CGAffineTransformMakeScale(1.0f / OLD_DEVICE_SCREEN_MULTIPLIER, 1.0f / OLD_DEVICE_SCREEN_MULTIPLIER)];
		[self.avc.view setCenter:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)];
		[UIView commitAnimations];
	}
}

- (void)handleTwoFingerSingleTap:(id)sender {
	UIView *h = self.headerController.view;
    
	////NSLog(@"twofingertap");
    
	// header hidden
	if (!h.userInteractionEnabled) {
		////NSLog(@"\tmake header visible");
		[self.infoButton setUserInteractionEnabled:YES];
		[h setUserInteractionEnabled:YES];
        
		[UIView animateWithDuration:0.25f
		                      delay:0.0f
		                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
		                 animations: ^{
                             [h setAlpha:1];
                             [self.infoButton setAlpha:1];
                         }
         
		                 completion: ^(BOOL finished) {
                         }
         
         ];
		[self.headerController showPopover];
        
		// header visible
	}
	else {
		/*
         // this version toggles everything (header and all)
         UIView *h = self.headerController.view;
         if( !self.headerController.isPopoverVisible ){
         
         [self.headerController showPopover];
         
         } else {
         [self.pop hide];
         [h setUserInteractionEnabled:NO];
         [self.infoButton setUserInteractionEnabled:NO];
         }
         
         [UIView animateWithDuration:0.25f
         delay:0.0f
         options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
         animations:^{
         [h setAlpha:(h.userInteractionEnabled) ? 1:0 ];
         [self.infoButton setAlpha:(h.userInteractionEnabled) ? 1:0 ];
         }
         completion:^(BOOL finished){
         [self.infoButton setUserInteractionEnabled:(self.infoButton.alpha==1)];
         }
         ];
		 */
		//UIView *h = self.headerController.view;
		[self.headerController togglePopover];
	}
}

- (void)enteredForeground {
	[self setDidJustWake:YES];
	UIView *h = self.headerController.view;
	[h setUserInteractionEnabled:YES];
	[self.infoButton setUserInteractionEnabled:YES];
    
	[UIView animateWithDuration:0.25f
	                      delay:0.0f
	                    options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
                         [h setAlpha:1.0f];
                         [self.infoButton setAlpha:1];
                     }
     
	                 completion:nil
     ];
	[self.zoomViewController hide];
	[self handleDoubleTap:nil];
    
	if (self.headerController.isPopoverVisible) {
		[self.headerController showPopover];
	}
	[self.colorMenuViewController wake];
}

- (void)loadExistingDrawing{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"savedstate.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL doesFileExist = [fileManager fileExistsAtPath:filePath];
    if (doesFileExist) {
        //NSLog(@"file exists.. attempting to restore...");
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
        EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
        
        
        // upside down and flipped
        UIImage *flipped = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationDownMirrored];
        
        // draw rotated image into a new image so we have a properly rotated image
        float scale = image.scale;
        short sx = scale * 0;
        short sy = scale * 0;
        short sw = scale * image.size.width;
        short sh = scale * image.size.height;
        UIGraphicsBeginImageContext(CGSizeMake(sw, sh));
        CGContextRef aContext = UIGraphicsGetCurrentContext();
        CGContextSetBlendMode(aContext, kCGBlendModeCopy);
        [flipped drawInRect:CGRectMake(sx, sy, sw, sh)];
        UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [jsv injectScreenShot:ret];
        [self.avc callJS:@"saveUndoState();"];
        
        [fileManager removeItemAtPath:filePath error:nil];
    }
    else {
        //NSLog(@"prev drawing does not exist");
    }
    
}

- (void)removeExistingDrawing{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"savedstate.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL doesFileExist = [fileManager fileExistsAtPath:filePath];
    if (doesFileExist) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

- (void)saveImageToDocuments:(UIImage*)image{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"savedstate.png"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL doesFileExist = [fileManager fileExistsAtPath:filePath];
    if (doesFileExist) {
        [fileManager removeItemAtPath:filePath error:nil];
    }

    BOOL success = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]; // PNG doesn't maintain orientation
    if ( success ){
        //NSLog(@"SAVE TEXTURE SUCCESS");
        
    } else {
        //NSLog(@"SAVE TEXTURE FAILED");
    }
}

#pragma mark - VLMHeaderDelegate

- (void)updateIndex:(NSInteger)index AndTitle:(NSString *)title {
	VLMToolCollection *tools = [VLMToolCollection instance];
	VLMToolData *item;
	if ([tools isToggleable]) {
		item = (VLMToolData *)[tools getSelectedToolFromEnabledIndex:index];
	}
	else {
		item = (VLMToolData *)[tools.tools objectAtIndex:index];
	}
	NSString *m = item.javascriptvalue;
	NSString *s = [NSString stringWithFormat:@"setDrawingMode(%@);", m];
	[self.avc callJS:s];
	[self.pop updatebuttons];
}

- (void)clearScreen {
	[self handleDoubleTap:nil];
	[self.avc callJS:@"clearScreen();"];
	if ([[VLMToolCollection instance] isSelectedToolSubtractive]) {
		[self.headerController resetToZero];
		[self updateHeader];
	}
//#ifdef USE_INCREMENTAL_SAVE
    if ( self.shouldRemoveExistingFile ){
        [self removeExistingDrawing];
    } else {
        // don't remove file first time through, since we might want to restore it
        [self setShouldRemoveExistingFile:YES];
    }
//#endif
	[Flurry endTimedEvent:FLURRY_CLEAR withParameters:nil];
	[Flurry logEvent:FLURRY_CLEAR withParameters:nil timed:YES];
}

- (void)screenCapture:(id)screenshotdelegate {
	EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
	jsv.screenShotDelegate = screenshotdelegate;
	[jsv requestScreenShot];
}

- (void)showPopover {
	[self.pop show];
	if (!self.didJustWake) {
		[self.colorMenuViewController hide];
	}
	else {
		[self setDidJustWake:NO];
	}
	[Flurry endTimedEvent:FLURRY_TOOLS_CLOSED withParameters:nil];
	[Flurry logEvent:FLURRY_TOOLS_OPEN timed:YES];
	[Flurry logEvent:FLURRY_PATH_MENU];
}

- (void)hidePopover {
	[self.pop hide];
	[self.colorMenuViewController hide];
	[Flurry endTimedEvent:FLURRY_TOOLS_OPEN withParameters:nil];
	[Flurry logEvent:FLURRY_TOOLS_CLOSED timed:YES];
}

- (void)requestUndo{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    VLMSettingsData *data = delegate.settings;
    if (!data.undoEnabled) return;
    
    NSInteger nextIndex = self.undoViewController.index - 1;//lastKnownUndoIndex - 1;
	if (nextIndex < 0) nextIndex = 0;
	if (nextIndex > self.undoViewController.numStates - 1) nextIndex = self.undoViewController.numStates - 1;
	if (nextIndex != self.undoViewController.index) {
		//NSLog(@"nextIndex: %d", nextIndex);
		NSString *s = [NSString stringWithFormat:@"restoreUndoStateAtIndex(%d);", nextIndex];
		[self.avc callJS:s];
	}
}

- (void)requestRedo{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    VLMSettingsData *data = delegate.settings;
    if (!data.undoEnabled) return;

    NSInteger nextIndex = self.undoViewController.index + 1;//lastKnownUndoIndex + 1;
	if (nextIndex < 0) nextIndex = 0;
	if (nextIndex > self.undoViewController.numStates - 1) nextIndex = self.undoViewController.numStates - 1;
	if (nextIndex != self.undoViewController.index) {
		////NSLog(@"nextIndex: %d", nextIndex);
		NSString *s = [NSString stringWithFormat:@"restoreUndoStateAtIndex(%d);", nextIndex];
		[self.avc callJS:s];
	}
}

#pragma mark - MenuDelegate

- (void)updateHeader {
	[self updateHeaderWithTitle:nil];
	/*
     VLMToolCollection *tools = [VLMToolCollection instance];
     VLMToolData *item = (VLMToolData *)[tools.tools objectAtIndex:tools.selectedIndex];
     VLMColorData *color = [[item colors] objectAtIndex:[item selectedColorIndex]];
     NSString *m = item.javascriptvalue;
     NSString *s = [NSString stringWithFormat:@"setDrawingModeAndColor(%@, '%@', %f);", m, color.name, color.opacity];
     [self.avc callJS:s];
	 */
}

- (void)updateHeaderWithTitle:(NSString *)title {
	NSInteger selectedindex = [[VLMToolCollection instance] getSelectedEnabledIndex];
	[self.headerController setSelectedIndex:selectedindex andTitle:title];
    
	VLMToolCollection *tools = [VLMToolCollection instance];
	VLMToolData *item = (VLMToolData *)[tools.tools objectAtIndex:tools.selectedIndex];
	VLMColorData *color = [[item colors] objectAtIndex:[item selectedColorIndex]];
    
	if (item.isSubtractive) {
		if (!color.isSubtractive) {
			[self.headerController showSubtitleWithText:@"inverted mode"];
		}
		else {
			[self.headerController hideSubtitle];
		}
	}
	else {
		if (color.isSubtractive) {
			[self.headerController showSubtitleWithText:@"eraser mode"];
		}
		else {
			[self.headerController hideSubtitle];
		}
	}
	NSString *m = item.javascriptvalue;
    
    int numComponents = CGColorGetNumberOfComponents(color.rgbaColor.CGColor);
    const CGFloat *cmps = CGColorGetComponents(color.rgbaColor.CGColor);
    NSInteger r = 0;
    NSInteger g = 0;
    NSInteger b = 0;
    CGFloat a = 0;
    
    if (numComponents == 4)
    {
        // rgb values + alpha
        r = lroundf(cmps[0]*255);;
        g = lroundf(cmps[1]*255);
        b = lroundf(cmps[2]*255);
        a = cmps[3];
        
    }else if(numComponents == 2){
        // greyscale, set rgb to the same value + alpha
        r = lroundf(cmps[0]*255);
        g = lroundf(cmps[0]*255);
        b = lroundf(cmps[0]*255);
        a = cmps[1];
    }
    
    numComponents = CGColorGetNumberOfComponents(color.buttoncolor.CGColor);
    cmps = CGColorGetComponents(color.buttoncolor.CGColor);

    NSInteger rr = 0;
    NSInteger gg = 0;
    NSInteger bb = 0;
    CGFloat aa = 0;
    
    if (numComponents == 4)
    {
        // rgb values + alpha
        rr = lroundf(cmps[0]*255);;
        gg = lroundf(cmps[1]*255);
        bb = lroundf(cmps[2]*255);
        aa = cmps[3];
        
    }else if(numComponents == 2){
        // greyscale, set rgb to the same value + alpha
        rr = lroundf(cmps[0]*255);
        gg = lroundf(cmps[0]*255);
        bb = lroundf(cmps[0]*255);
        aa = cmps[1];
    }

    
    
	NSString *s = [NSString stringWithFormat:@"setDrawingModeAndColor(%@, '%@', %i, %i, %i, %f,  %i, %i, %i, %f);", m, color.name, r, g, b, a, rr, gg, bb, aa];
    NSLog(s);
	[self.avc callJS:s];
    
	NSString *name = [item.name stringByReplacingOccurrencesOfString:@" " withString:@""];
	//NSString *eventpath = [NSString stringWithFormat:@"%@ - %@", FLURRY_PATH_MENU, name];
	//[Flurry logEvent:eventpath];
    
	NSString *eventpath2 = [NSString stringWithFormat:@"%@ - %@ - %f%@", FLURRY_PATH_MENU, name, a, (color.isSubtractive) ? @"_erase":@""];
	[Flurry logEvent:eventpath2];
    
	////NSLog(eventpath2);
}

- (void)refreshData {
	VLMToolCollection *toolcollection = [VLMToolCollection instance];
	NSMutableArray *enabledtools = [toolcollection getEnabledTools];
	[self.headerController setHeadings:enabledtools];
    
	VLMToolData *selecteditem = (VLMToolData *)[toolcollection.tools objectAtIndex:toolcollection.selectedIndex];
    
	if (!selecteditem.enabled) {
		[self.headerController setSelectedIndex:-1 andTitle:selecteditem.name];
		return;
	}
    
	NSInteger selectedenabledindex = [toolcollection getSelectedEnabledIndex];
    
	if (selectedenabledindex == -1) {
		[self.headerController setSelectedIndex:0 andTitle:selecteditem.name animated:NO];
	}
	else {
		[self.headerController setSelectedIndex:selectedenabledindex andTitle:nil animated:NO];
	}
}

- (void)showColorMenu {
	[self.colorMenuViewController show];
	[Flurry endTimedEvent:FLURRY_COLORS_CLOSED withParameters:nil];
	[Flurry logEvent:FLURRY_COLORS_OPEN timed:YES];
}

- (void)hideColorMenu {
	[self.colorMenuViewController hide];
	[Flurry endTimedEvent:FLURRY_COLORS_OPEN withParameters:nil];
	[Flurry logEvent:FLURRY_COLORS_CLOSED timed:YES];
}

- (void)updateColorMenu {
	[self.colorMenuViewController update];
}

- (BOOL)isColorMenuOpen {
	return [self.colorMenuViewController isOpen];
}


#pragma mark - public () for cross js communication
- (void)updateUndoCount:(NSInteger)count {
	//NSLog(@"mainviewcontroller:updateundocount(%d)", count);
	[self.undoViewController setNumStates:count];
}

- (void)updateUndoIndex:(NSInteger)index {
	//NSLog(@"mainviewcontroller:updateundoindex(%d)", index);
    //[self setLastKnownUndoIndex:index];
	[self.undoViewController setIndex:index];
	[self.undoViewController update];
    [self.headerController updateUndoIndex:index andUndoCount:self.undoViewController.numStates];
}

- (void)saveStateBeforeTerminating{
    //NSLog(@"savestatebeforeterminating - requesting screenshot");
    
    EJJavaScriptView *jsv = (EJJavaScriptView *)self.avc.view;
    [jsv setScreenShotDelegate:self];
    [jsv requestScreenShot];
    
}

- (void)saveStateInBackground{
#ifdef USE_INCREMENTAL_SAVE
    //NSLog(@"SAVESTATEINBACKGROUND");
    
    // NOTE: may want to have a flag that indicates that it's locked
    // to prevent this from being called while already saving
    
    [self setShouldSaveInBackground:YES];
    EJJavaScriptView *jsv = (EJJavaScriptView *)self.avc.view;
    [jsv setScreenShotDelegate:self];
    [jsv requestScreenShot];
#endif
}

- (void)hideStatusBarIfNeeded{
    // ios 7 correction
    if (![UIApplication sharedApplication].statusBarHidden){
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        /*
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }
         UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
         [self.view setFrame:CGRectMake(0,0,window.frame.size.width, window.frame.size.height)];
         */
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
	////NSLog(@"found image picked: %@", img==nil ? @"false" : @"true" );
	EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
    
	UIImage *padded = [self getPaddedImageForImage:img AndSize:self.view.frame.size];
    
	[jsv injectScreenShot:padded];
	[self.avc callJS:@"saveUndoState();"];
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.headerController dismissPopoverController];
	}
	else {
		[picker dismissModalViewControllerAnimated:YES];
	}
	[self.headerController cleanupImagePicker];

#ifdef USE_INCREMENTAL_SAVE
    [self saveStateInBackground];
#endif

    [self hideStatusBarIfNeeded];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
    [self hideStatusBarIfNeeded];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	// do nothing
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	// do nothing
}

- (UIImage *)getPaddedImageForImage:(UIImage *)image AndSize:(CGSize)size {
    if (!self.avc.shouldDoubleResolution) {
        CGFloat scale = OLD_DEVICE_SCREEN_MULTIPLIER;
        size.width *= scale;
        size.height *= scale;
    }
    else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            CGFloat scale = [[UIScreen mainScreen] scale];
            size.width *= scale;
            size.height *= scale;
        }
    }
    
	CGSize inputSize = image.size;
	CGRect outputRect = CGRectMake(0, 0, size.width, size.height);
    
	CGImageRef iref = image.CGImage;
	if (inputSize.height >= inputSize.width) { //portrait
		if (inputSize.height >= size.height) {
			outputRect.size.width = inputSize.width / inputSize.height * outputRect.size.height;
		}
		else {
			outputRect.size.height = inputSize.height;
			outputRect.size.width = inputSize.width / inputSize.height * outputRect.size.height;
		}
		outputRect.origin.y = (size.height - outputRect.size.height) / 2.0f;
		outputRect.origin.x = (size.width - outputRect.size.width) / 2.0f;
	}
	else {  //landscape
		if (inputSize.width >= size.width) {
			outputRect.size.height = inputSize.height / inputSize.width * outputRect.size.width;
		}
		else {
			outputRect.size.width = inputSize.width;
			outputRect.size.height = inputSize.height / inputSize.width * outputRect.size.width;
		}
		outputRect.origin.y = (size.height - outputRect.size.height) / 2.0f;
		outputRect.origin.x = (size.width - outputRect.size.width) / 2.0f;
	}
    
	UIColor *bgcolor = [UIColor colorWithHue:60.0f / 360.0f saturation:0.04f brightness:0.95f alpha:1.0f];
    
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [bgcolor CGColor]);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
	CGContextDrawImage(context, outputRect, iref);
    
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(VLMFlipViewController *)controller {
	////NSLog(@"HERE");
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
	else {
		[self.flipsidePopoverController dismissPopoverAnimated:YES];
	}
}

- (void)infoButtonTapped:(id)sender {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		VLMFlipViewController *controller = [[VLMFlipViewController alloc] initWithNibName:nil bundle:nil];
		controller.delegate = self;
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
		[self presentModalViewController:controller animated:YES];
	}
	else {
		if (!self.flipsidePopoverController) {
			VLMFlipViewController *controller = [[VLMFlipViewController alloc] initWithNibName:nil bundle:nil];
			controller.delegate = self;
            
            
			self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
		}
		if ([self.flipsidePopoverController isPopoverVisible]) {
			[self.flipsidePopoverController dismissPopoverAnimated:YES];
		}
		else {
			[self.flipsidePopoverController presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	}
}

#pragma mark - Rotation Handling
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (firstTime) {
		firstTime = NO;
		if (interfaceOrientation == UIInterfaceOrientationPortrait) {
			return YES;
		}
		return NO;
	}
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if (interfaceOrientation == UIInterfaceOrientationPortrait) {
			return YES;
		}
		return NO;
	}
	else {
		return YES;
	}
}

- (NSUInteger)supportedInterfaceOrientations {
	if (firstTime) {
		firstTime = NO;
		return UIInterfaceOrientationMaskPortrait;
	}
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskAllButUpsideDown;
	}
	else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

- (void)didRotate:(NSNotification *)notification {
	////NSLog(@"didrotate %@", notification);
    
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
    
	if (self.flipsidePopoverController != nil) {
		if ([self.flipsidePopoverController isPopoverVisible]) {
			[self.flipsidePopoverController dismissPopoverAnimated:YES];
		}
	}
}

#pragma mark - VLMScreenshotDelegate
- (void)screenShotFound:(UIImage *)found {
    //NSLog(@"found screenshot");
    if (self.shouldSaveInBackground){
        [self performSelectorInBackground:@selector(saveImageToDocuments:) withObject:found];
        [self setShouldSaveInBackground:NO];
    } else {
        [self saveImageToDocuments:found];
    }
}

- (UIImage *)screenshotToRestore {
	return nil;
}

    
    
#pragma mark - Vector shit
    
-(void) renderElement:(AbstractBezierPathElement*)element fromPreviousElement:(AbstractBezierPathElement*)previousElement{
    // setup the correct initial width
    //__block CGFloat lastWidth;
    /*
    CGFloat lastWidth;
    if(previousElement){
        lastWidth = previousElement.width;
    }else{
        lastWidth = element.width;
    }
     */
    CGFloat scale = 1;
    
    
    
    // fetch the vertex data from the element
    struct Vertex* vertexBuffer = [element generatedVertexArrayWithPreviousElement:previousElement forScale:scale];
    
    // if the element has any data, then draw it
    //
    int numberOfSteps = element.numberOfSteps;
    NSMutableString *points = [NSMutableString stringWithString:@""];
    
    for(int step = 0; step < numberOfSteps; step++) {
        CGFloat x = vertexBuffer[step].Position[0];
        CGFloat y = vertexBuffer[step].Position[1];
        CGFloat p = vertexBuffer[step].Size;
        [points appendFormat:@"{x:%f,y:%f,p:%f}", x, y, p];
        if (step < numberOfSteps - 1 ){
            [points appendString:@","];
        }
        //CGFloat size = vertexBuffer[step].Size;
    }
    NSString *s = [NSString stringWithFormat:@"continueStrokeWithPoints({travel:%f, arr:[%@]});", self.travelDistance, points];
    ////NSLog(@"%@", s);
    [self.avc callJS:s];
}
    
    /**
     * Drawings a line onscreen based on where the user touches
     *
     * this will add the end point to the current stroke, and will
     * then render that new stroke segment to the gl context
     *
     * it will smooth a rounded line from the previous segment, and will
     * also smooth the width and color transition
     */
- (void) addLineToAndRenderStroke:(SmoothStroke*)currentStroke toPoint:(CGPoint)end toWidth:(CGFloat)width toColor:(UIColor*)color{
    
    
    if(![currentStroke addPoint:end withWidth:width andColor:color]) return;

    // fetch the current and previous elements
    // of the stroke. these will help us
    // step over their length for drawing
    AbstractBezierPathElement* previousElement = [currentStroke.segments lastObject];
    
    //
    // ok, now we have the current + previous stroke segment
    // so let's set to drawing it!
    [self renderElement:[currentStroke.segments lastObject] fromPreviousElement:previousElement];
}
    
    


@end
