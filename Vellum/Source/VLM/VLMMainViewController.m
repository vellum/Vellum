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
#import "VLMUndoViewController.h"
#import "VLMConstants.h"
#import "UINavigationBar+Fat.h"


@interface VLMMainViewController ()

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        firstTime = YES;
    }
    return self;
}

- (id)initWithEJAppViewController:(EJAppViewController*)appViewController{
    self = [super init];
    if (self) {
        firstTime = YES;
        [self setAvc:appViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setIsPortrait:YES];
    CGRect frame = UIScreen.mainScreen.bounds;
    UIView *t = [[UIView alloc] initWithFrame:frame];
    [t setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    //EJAppViewController *vc = [[EJAppViewController alloc] init];
    VLMZoomViewController *z = [[VLMZoomViewController alloc] init];
    VLMUndoViewController *uvc = [[VLMUndoViewController alloc] init];
    
    VLMDrawHeaderController *h = [[VLMDrawHeaderController alloc] init];
    [h setDelegate:self];
    
    UIButton *ib = [UIButton buttonWithType:UIButtonTypeInfoDark];
    //[ib setBackgroundColor:[UIColor redColor]];
    CGFloat margin = 15;
    [ib setFrame:CGRectMake(ib.frame.origin.x-margin, ib.frame.origin.y - margin,
                            ib.frame.size.width+margin*2, ib.frame.size.height+margin*2)];

    [ib setFrame:CGRectMake(frame.size.width-ib.frame.size.width, frame.size.height-ib.frame.size.height, ib.frame.size.width, ib.frame.size.height)];
    [ib addTarget:self action:@selector(infoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [ib setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];

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
    
    VLMTapGestureRecognizer *singleTap = [[VLMTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setCancelsTouchesInView:NO];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [t addGestureRecognizer:pinch];
    [t addGestureRecognizer:twoFingerPan];
    [t addGestureRecognizer:oneFingerPan];
    [t addGestureRecognizer:doubleTap];
    [t addGestureRecognizer:singleTap];
    
    // only enable 3 finger undo for small screen devices
    // to counter glreadpixels performance problems
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [t addGestureRecognizer:threeFingerPan];
    }
    
    VLMPopMenuViewController *poppy = [[VLMPopMenuViewController alloc] init];
    [poppy setDelegate:self];
    [self.view addSubview:poppy.view];
    [self setPop:poppy];
    
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
        
        
        //[self.undoManager dropAllAfterCurrent];
        return;
    } else if ([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        NSString *s = [NSString stringWithFormat:@"endStroke(%f,%f);", p.x, p.y];
        [self.avc callJS:s];
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
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGPoint p = [(UIPanGestureRecognizer *)sender translationInView : window];//self.touchCaptureView];
    [sender setTranslation:CGPointZero inView:window];//self.touchCaptureView];
    CGPoint c = self.avc.view.center;
    c.x += p.x; c.y += p.y;
    [self.avc.view setCenter:c];
}

- (void)handleThreeFingerPan:(id)sender {
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
        NSLog(@"nextIndex: %d", nextIndex);
        NSString *s = [NSString stringWithFormat:@"restoreUndoStateAtIndex(%d);", nextIndex];
        [self.avc callJS:s];
    }
}

- (void)handlePinch:(id)sender {
    VLMPinchGestureRecognizer *pgr = (VLMPinchGestureRecognizer *)sender;
    int numberOfTouches = pgr.numberOfTouches;

    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect bounds = window.frame;
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if ([pgr state] == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [sender locationInView:self.avc.view];
        if ( !self.avc.shouldDoubleResolution ){
            [self setPinchLastPoint:CGPointMake(location.x / bounds.size.width, location.y / bounds.size.height)]; // this is now a percentage value
        } else {
            // 3gs gets this
            [self setPinchLastPoint:CGPointMake(location.x / (bounds.size.width*OLD_DEVICE_SCREEN_MULTIPLIER), location.y / (bounds.size.height*OLD_DEVICE_SCREEN_MULTIPLIER))]; // this is now a percentage value
        }
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
    
    if ( !self.avc.shouldDoubleResolution ){
        bounds.size.width *= self.pinchAccumulatedScale;
        bounds.size.height *= self.pinchAccumulatedScale;
        
        CGPoint xy = [sender locationInView:window];
        CGPoint topleft = CGPointMake(xy.x - self.pinchLastPoint.x * bounds.size.width, xy.y - self.pinchLastPoint.y * bounds.size.height);
        bounds.origin = topleft;
        [self.avc.view setTransform:CGAffineTransformMakeScale(self.pinchAccumulatedScale, self.pinchAccumulatedScale)];
        [self.avc.view setCenter:CGPointMake(topleft.x + bounds.size.width / 2, topleft.y + bounds.size.height / 2)];
        
    } else {
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
    if( self.headerController.isPopoverVisible ){
        if ( h.userInteractionEnabled ){
            [self.pop show];
        } else {
            [self.pop hide];
        }
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
}

- (void)handleDoubleTap:(id)sender {
    VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
    if (tgr.numberOfTouches > 1) return;
    
    if ( !self.avc.shouldDoubleResolution ) {
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
        
    } else {
        [self.zoomViewController setText:round(1.0f/OLD_DEVICE_SCREEN_MULTIPLIER*100.0f)];
        self.pinchAccumulatedScale = 1.0f/OLD_DEVICE_SCREEN_MULTIPLIER;
        CGRect bounds = [[UIScreen mainScreen] bounds];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.2];
        [self.avc.view setTransform:CGAffineTransformMakeScale(1.0f/OLD_DEVICE_SCREEN_MULTIPLIER, 1.0f/OLD_DEVICE_SCREEN_MULTIPLIER)];
        [self.avc.view setCenter:CGPointMake(bounds.size.width / 2, bounds.size.height / 2)];
        [UIView commitAnimations];
        
    }

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


#pragma mark - VLMHeaderDelegate

- (void)updateIndex:(NSInteger)index AndTitle:(NSString *)title {
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *item;
    if ( [tools isToggleable] ){
        item = (VLMToolData *)[tools getSelectedToolFromEnabledIndex:index];
    } else {
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


#pragma mark - public () for cross js communication
- (void)updateUndoCount:(NSInteger)count {
    NSLog(@"mainviewcontroller:updateundocount(%d)", count);
    [self.undoViewController setNumStates:count];
}

- (void)updateUndoIndex:(NSInteger)index {
    NSLog(@"mainviewcontroller:updateundoindex(%d)", index);
    [self.undoViewController setIndex:index];
    [self.undoViewController update];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * img = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"found image picked: %@", img==nil ? @"false" : @"true" );
    EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
    
    UIImage *padded = [self getPaddedImageForImage:img AndSize:self.view.frame.size];
    
    [jsv injectScreenShot:padded];
    [self.avc callJS:@"saveUndoState();"];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.headerController dismissPopoverController];
    } else {
        [picker dismissModalViewControllerAnimated:YES];
    }
    [self.headerController cleanupImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissModalViewControllerAnimated:YES];
    // do nothing
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // do nothing
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // do nothing
}

- (UIImage*)getPaddedImageForImage:(UIImage*)image AndSize:(CGSize)size{
    BOOL isRetina = NO;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
        isRetina = YES;
        CGFloat scale = [[UIScreen mainScreen] scale];
        size.width *= scale;
        size.height *= scale;
    }
    
    CGSize inputSize = image.size;
    CGRect outputRect = CGRectMake(0,0,size.width,size.height);

    CGImageRef iref = image.CGImage;
    if ( inputSize.height >= inputSize.width ){//portrait
        
        if ( inputSize.height >= size.height ){
            outputRect.size.width = inputSize.width/inputSize.height * outputRect.size.height;
        } else {
            outputRect.size.height = inputSize.height;
            outputRect.size.width = inputSize.width/inputSize.height * outputRect.size.height;
        }
        outputRect.origin.y = (size.height-outputRect.size.height) / 2.0f;
        outputRect.origin.x = (size.width-outputRect.size.width) / 2.0f;
    
    } else {//landscape
        
        if ( inputSize.width >= size.width ){
            outputRect.size.height = inputSize.height/inputSize.width * outputRect.size.width;
        } else {
            outputRect.size.width = inputSize.width;
            outputRect.size.height = inputSize.height/inputSize.width * outputRect.size.width;
        }
        outputRect.origin.y = (size.height-outputRect.size.height) / 2.0f;
        outputRect.origin.x = (size.width-outputRect.size.width) / 2.0f;
    }
    
    UIColor *bgcolor = [UIColor colorWithHue:60.0f/360.0f saturation:0.04f brightness:0.95f alpha:1.0f];
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [bgcolor CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    CGContextDrawImage(context, outputRect, iref);
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
    
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(VLMFlipViewController *)controller
{
    NSLog(@"HERE");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)infoButtonTapped:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

        
        VLMFlipViewController *controller = [[VLMFlipViewController alloc] initWithNibName:nil bundle:nil];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self presentModalViewController:controller animated:YES];

    } else {
        if (!self.flipsidePopoverController) {
            VLMFlipViewController *controller = [[VLMFlipViewController alloc] initWithNibName:nil bundle:nil];
            controller.delegate = self;


            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromRect:self.infoButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }
    }
}

#pragma mark - Rotation Handling
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ( firstTime ) {
        firstTime = NO;
        if (interfaceOrientation==UIInterfaceOrientationPortrait){
            return YES;
        }
        return NO;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         if (interfaceOrientation==UIInterfaceOrientationPortrait){
            return YES;
        }
        return NO;
        
    } else {
        return YES;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ( firstTime ) {
        firstTime = NO;
        return UIInterfaceOrientationMaskPortrait;
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didRotate:(NSNotification *)notification {

    NSLog(@"didrotate %@", notification);

    BOOL isNowPortrait = self.isPortrait;
    int type = [[UIDevice currentDevice] orientation];
    if (type == 1) {
        isNowPortrait = YES;
    }else if(type ==2){
        isNowPortrait = YES;
    }else if(type ==3){
        isNowPortrait = NO;
    }else if(type ==4){
        isNowPortrait = NO;
    }
    if ( isNowPortrait == self.isPortrait ) return;

    [self setIsPortrait:isNowPortrait];
    
    if ( self.flipsidePopoverController != nil ){
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        }
    }
    
}
@end
