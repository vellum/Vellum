//
//  VLMMainViewController.m
//  Ejecta
//
//  Created by David Lu on 4/21/13.
//
//

#import "VLMMainViewController.h"
#import "VLMDrawHeaderController.h"
#import "VLMZoomViewController.h"
#import "VLMPanGestureRecognizer.h"
#import "VLMPinchGestureRecognizer.h"
#import "VLMSinglePanGestureRecognizer.h"
#import "EJAppViewController.h"
#import "VLMTapGestureRecognizer.h"
#import "VLMPopMenuViewController.h"
#import "VLMToolCollection.h"
#import "VLMToolData.h"
#import "DDPageControl.h"
#import "VLMUndoState.h"
#import "VLMUndoManager.h"

#define JOT_X_OFFSET 4.0f // compensate for jot stylus
#define JOT_Y_OFFSET 6.0f

@interface VLMMainViewController ()

@property (strong, nonatomic) VLMDrawHeaderController *headerController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;
@property (strong, nonatomic) EJAppViewController *avc;
@property (strong, nonatomic) VLMPopMenuViewController *pop;
@property (strong, nonatomic) VLMUndoManager *undoManager;
@property CGFloat pinchLastScale;
@property CGPoint pinchLastPoint;
@property CGFloat pinchAccumulatedScale;

- (void)handleOneFingerPan:(id)sender;
- (void)handleTwoFingerPan:(id)sender;
- (void)handleThreeFingerPan:(id)sender;
- (void)handlePinch:(id)sender;
- (void)handleSingleTap:(id)sender;
- (void)handleDoubleTap:(id)sender;
- (void)enteredForeground;
- (void)saveUndoState;

@end

@implementation VLMMainViewController

@synthesize headerController;
@synthesize touchCaptureView;
@synthesize zoomViewController;
@synthesize avc;
@synthesize undoManager;
@synthesize pinchLastScale;
@synthesize pinchLastPoint;
@synthesize pinchAccumulatedScale;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect frame = UIScreen.mainScreen.bounds;
    UIView *t = [[UIView alloc] initWithFrame:frame];
    EJAppViewController *vc = [[EJAppViewController alloc] init];
    VLMZoomViewController *z = [[VLMZoomViewController alloc] init];
    
    VLMDrawHeaderController *h = [[VLMDrawHeaderController alloc] init];
    NSMutableArray *tools = [[VLMToolCollection instance] getEnabledTools];
    [h setHeadings:tools];
    [h setDelegate:self];
    
    [self setPinchLastScale:1.0f];
    [self setPinchAccumulatedScale:1.0f];
    
    [self.view setFrame:frame];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    [self.view addSubview:vc.view];
    [self.view addSubview:z.view];
    [self.view addSubview:t];
    [self.view addSubview:h.view];
    
    [self setAvc:vc];
    [self setZoomViewController:z];
    [self setTouchCaptureView:t];
    [self setHeaderController:h];
    
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
    
    VLMTapGestureRecognizer *singleTap = [[VLMTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setCancelsTouchesInView:NO];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [t addGestureRecognizer:pinch];
    [t addGestureRecognizer:twoFingerPan];
    [t addGestureRecognizer:oneFingerPan];
    [t addGestureRecognizer:doubleTap];
    [t addGestureRecognizer:singleTap];
    [t addGestureRecognizer:threeFingerPan];
    
    VLMPopMenuViewController *poppy = [[VLMPopMenuViewController alloc] init];
    [poppy setDelegate:self];
    [self.view addSubview:poppy.view];
    [self setPop:poppy];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enteredForeground)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [self.headerController updatePage];
    
    VLMUndoManager *um = [[VLMUndoManager alloc] init];
    [self setUndoManager:um];
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
    
    if ([pgr state] == UIGestureRecognizerStateBegan) {
        NSString *s = [NSString stringWithFormat:@"beginStroke(%f,%f);", p.x, p.y];
        [self.avc callJS:s];
        s = [NSString stringWithFormat:@"setZoom( %f );", self.zoomViewController.zoomlevel];
        [self.avc callJS:s];
        return;
    } else if ([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        NSString *s = [NSString stringWithFormat:@"endStroke(%f,%f);", p.x, p.y];
        [self.avc callJS:s];
        [self saveUndoState];
        return;
    }
    NSString *s = [NSString stringWithFormat:@"continueStroke(%f,%f);", p.x, p.y];
    [self.avc callJS:s];
}

- (void)handleTwoFingerPan:(id)sender {
    VLMPanGestureRecognizer *pgr = (VLMPanGestureRecognizer *)sender;
    if (pgr.numberOfTouches != 2) {
        return;
    } else if ([pgr state] == UIGestureRecognizerStateBegan) {
        return;
    } else if ([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        return;
    }
    CGPoint p = [(UIPanGestureRecognizer *)sender translationInView : self.touchCaptureView];
    [sender setTranslation:CGPointZero inView:self.touchCaptureView];
    CGPoint c = self.avc.view.center;
    c.x += p.x; c.y += p.y;
    [self.avc.view setCenter:c];
}

- (void)handleThreeFingerPan:(id)sender {
    VLMPanGestureRecognizer *pgr = (VLMPanGestureRecognizer *)sender;
    if (pgr.numberOfTouches != 3) return;
}

- (void)handlePinch:(id)sender {
    VLMPinchGestureRecognizer *pgr = (VLMPinchGestureRecognizer *)sender;
    int numberOfTouches = pgr.numberOfTouches;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if ([pgr state] == UIGestureRecognizerStateBegan) {
        CGPoint location = [sender locationInView:self.avc.view];
        [self setPinchLastPoint:CGPointMake(location.x / bounds.size.width, location.y / bounds.size.height)]; // this is now a percentage value
        [self setPinchLastScale:1.0f];
        [self.zoomViewController show];
        return;
    } else if ([pgr state] == UIGestureRecognizerStateEnded) {
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
    
    bounds.size.width *= self.pinchAccumulatedScale;
    bounds.size.height *= self.pinchAccumulatedScale;
    
    CGPoint xy = [sender locationInView:[sender view]];
    CGPoint topleft = CGPointMake(xy.x - self.pinchLastPoint.x * bounds.size.width, xy.y - self.pinchLastPoint.y * bounds.size.height);
    bounds.origin = topleft;
    [self.avc.view setTransform:CGAffineTransformMakeScale(self.pinchAccumulatedScale, self.pinchAccumulatedScale)];
    [self.avc.view setCenter:CGPointMake(topleft.x + bounds.size.width / 2, topleft.y + bounds.size.height / 2)];
    
    int val = round(self.pinchAccumulatedScale * 100);
    [zoomViewController setText:val];
}

- (void)handleSingleTap:(id)sender {
    if (self.headerController.isPopoverVisible) return;
    
    VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
    if (tgr.numberOfTouches > 1) return;
    
    UIView *h = self.headerController.view;
    [h setUserInteractionEnabled:!h.userInteractionEnabled];
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [h setAlpha:(h.userInteractionEnabled) ? 1:0 ];
                     }
     
                     completion:nil
     ];
}

- (void)handleDoubleTap:(id)sender {
    VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
    if (tgr.numberOfTouches > 1) return;
    [self.zoomViewController setText:100];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.2];
    [self.avc.view setTransform:CGAffineTransformMakeScale(1, 1)];
    [self.avc.view setCenter:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)];
    [UIView commitAnimations];
    self.pinchAccumulatedScale = 1.0f;
}

- (void)enteredForeground {
    UIView *h = self.headerController.view;
    [h setUserInteractionEnabled:YES];
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [h setAlpha:1.0f];
                     }
     
                     completion:nil
     ];
    [self.zoomViewController hide];
    [self handleDoubleTap:nil];
}

- (void)saveUndoState{
    if (![self.undoManager shouldSaveState] ) return;
    
    // request undo
    EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
    [jsv setUndoScreenShotDelegate:self];
    [jsv requestUndoScreenShot];
}

#pragma mark - VLMHeaderDelegate

- (void)updateIndex:(NSInteger)index AndTitle:(NSString *)title {
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *item = (VLMToolData *)[tools getSelectedToolFromEnabledIndex:index];
    
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
    }
}

- (void)screenCapture:(id)screenshotdelegate {
    EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
    jsv.screenShotDelegate = screenshotdelegate;
    [jsv requestScreenShot];
}

- (void)showPopover {
    [self.pop show];
}

- (void)hidePopover {
    [self.pop hide];
}

#pragma mark - MenuDelegate

- (void)updateHeader {
    [self updateHeaderWithTitle:nil];
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *item = (VLMToolData *)[tools.tools objectAtIndex:tools.selectedIndex];
    
    NSString *m = item.javascriptvalue;
    NSString *s = [NSString stringWithFormat:@"setDrawingMode(%@);", m];
    [self.avc callJS:s];
}

- (void)updateHeaderWithTitle:(NSString *)title {
    NSInteger selectedindex = [[VLMToolCollection instance] getSelectedEnabledIndex];
    [self.headerController setSelectedIndex:selectedindex andTitle:title];
    
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *item = (VLMToolData *)[tools.tools objectAtIndex:tools.selectedIndex];
    
    NSString *m = item.javascriptvalue;
    NSString *s = [NSString stringWithFormat:@"setDrawingMode(%@);", m];
    [self.avc callJS:s];
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
    } else {
        [self.headerController setSelectedIndex:selectedenabledindex andTitle:nil animated:NO];
    }
}

#pragma mark - VLMScreenShotDelegate

- (void)screenShotFound:(UIImage *)found{
    // send this thing to the
    NSLog(@"mainviewcontroller: screenshotfound");
    if ([self.undoManager shouldSaveState]){
        [self.undoManager saveState:found];
    }
}

@end
