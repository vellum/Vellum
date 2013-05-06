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

@interface VLMMainViewController ()

@property (strong, nonatomic) VLMDrawHeaderController *headerController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;
@property (strong, nonatomic) EJAppViewController *avc;
@property (strong, nonatomic) VLMPopMenuViewController *pop;
@property CGFloat pinchLastScale;
@property CGPoint pinchLastPoint;
@property CGFloat pinchAccumulatedScale;

@end

@implementation VLMMainViewController

@synthesize headerController;
@synthesize touchCaptureView;
@synthesize zoomViewController;
@synthesize avc;
@synthesize pinchLastScale;
@synthesize pinchLastPoint;
@synthesize pinchAccumulatedScale;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad{

    [super viewDidLoad];

    self.pinchLastScale = 1.0f;
    self.pinchAccumulatedScale = 1.0f;
    CGRect frame = UIScreen.mainScreen.bounds;

    BOOL landscapeMode = [[[NSBundle mainBundle] infoDictionary][@"UIInterfaceOrientation"]
                          hasPrefix:@"UIInterfaceOrientationLandscape"];
    if( landscapeMode ) {
        frame.size = CGSizeMake(frame.size.height, frame.size.width);
    }
    
    self.view.frame = frame;
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
    EJAppViewController *vc = [[EJAppViewController alloc] init];
    [self.view addSubview:vc.view];
    self.avc = vc;
    
    // - - - - - - - - - - - - - - - - - - - - -
    // add zoom indicator
    VLMZoomViewController *z = [[VLMZoomViewController alloc] init];
    [self.view addSubview:z.view];
    self.zoomViewController = z;
    
    // - - - - - - - - - - - - - - - - - - - - -
    // add touch capture layer
    UIView *t = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:t];
    self.touchCaptureView = t;

    // - - - - - - - - - - - - - - - - - - - - -
    // add header
    VLMDrawHeaderController *h = [[VLMDrawHeaderController alloc] init];
    [self.view addSubview:h.view];
    self.headerController = h;
    [h setHeadings:[NSArray arrayWithObjects:@"Lines", @"Dots", @"Ink", @"Scratch", nil]];
    h.delegate = self;
    
    VLMPanGestureRecognizer *twoFingerPan = [[VLMPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.maximumNumberOfTouches = 2;
    twoFingerPan.delegate = self;
    
    VLMSinglePanGestureRecognizer *oneFingerPan = [[VLMSinglePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
    oneFingerPan.delegate = self;
    
    VLMPanGestureRecognizer *threeFingerPan = [[VLMPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreeFingerPan:)];
    threeFingerPan.minimumNumberOfTouches = 3;
    threeFingerPan.maximumNumberOfTouches = 3;
    threeFingerPan.delegate = self;

    VLMPinchGestureRecognizer *pinch = [[VLMPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    
    VLMTapGestureRecognizer *doubleTap = [[VLMTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    VLMTapGestureRecognizer *singleTap =[[VLMTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.cancelsTouchesInView = NO;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [t addGestureRecognizer:pinch];
    [t addGestureRecognizer:twoFingerPan];
    [t addGestureRecognizer:oneFingerPan];
    [t addGestureRecognizer:doubleTap];
    [t addGestureRecognizer:singleTap];
    [t addGestureRecognizer:threeFingerPan];
    
    // - - - - - -
    VLMPopMenuViewController *poppy = [[VLMPopMenuViewController alloc] init];
    [self.view addSubview:poppy.view];
    self.pop = poppy;
}

#pragma mark - UIGestureRecco Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)otherGestureRecognizer;
        if (pgr.minimumNumberOfTouches == 3) return NO;
    }
    /*
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
        UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)gestureRecognizer;
        if ( pgr.minimumNumberOfTouches == 3) return NO;
    }*/
    return YES;
}


- (void)handleTwoFingerPan:(id)sender{
    
    VLMPanGestureRecognizer *pgr = (VLMPanGestureRecognizer *)sender;
    if (pgr.numberOfTouches > 2) return;

    if ( [pgr numberOfTouches] == 1 ) {
        return;
    } else if ( [pgr numberOfTouches] >= 3 ) {
        return;
    } else if([pgr state] == UIGestureRecognizerStateBegan) {
        return;
    } else if([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        return;
    }
    
    CGPoint p = [(UIPanGestureRecognizer *)sender translationInView:self.touchCaptureView];
    [sender setTranslation:CGPointZero inView:self.touchCaptureView];
    CGPoint c = self.avc.view.center;
    c.x += p.x; c.y += p.y;
    [self.avc.view setCenter:c];
}

- (void)handleThreeFingerPan:(id)sender{
    VLMPanGestureRecognizer *pgr = (VLMPanGestureRecognizer *)sender;
    if (pgr.numberOfTouches != 3) return;
    NSLog(@"three");
}

- (void)handleOneFingerPan:(id)sender{
    
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)sender;
    NSLog(@"onefingerpan, %i", [pgr numberOfTouches]);
    CGPoint p = [pgr locationInView:self.avc.view];
    
    if([pgr state] == UIGestureRecognizerStateBegan) {
        NSString *s = [NSString stringWithFormat:@"beginStroke(%f,%f);", p.x, p.y];
        [self.avc callJS:s];
        
        s = [NSString stringWithFormat:@"setZoom( %f );", self.zoomViewController.zoomlevel];
        [self.avc callJS:s];
        return;
        
    } else if([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        NSString *s = [NSString stringWithFormat:@"endStroke(%f,%f);", p.x, p.y];
        [self.avc callJS:s];
        return;
    }
    NSString *s = [NSString stringWithFormat:@"continueStroke(%f,%f);", p.x, p.y];
    [self.avc callJS:s];
    
}

- (void) handlePinch:(id)sender{

    VLMPinchGestureRecognizer *pgr = (VLMPinchGestureRecognizer*)sender;
    //if (pgr.numberOfTouches > 2) return;

    int numberOfTouches = pgr.numberOfTouches;
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if([pgr state] == UIGestureRecognizerStateBegan) {
        self.pinchLastScale = 1.0;
        self.pinchLastPoint = [sender locationInView:self.avc.view];
        self.pinchLastPoint = CGPointMake(self.pinchLastPoint.x/bounds.size.width, self.pinchLastPoint.y/bounds.size.height); // this is now a percentage value
        [self.zoomViewController show];
        return;
    } else if([pgr state] == UIGestureRecognizerStateEnded) {
        NSLog(@"pinch / ended / numtouches: %d", numberOfTouches);
        [self.zoomViewController hide];
        return;
    }
    if ( numberOfTouches == 1 ) {
        NSLog(@"pinch / numtouches == 1");
        [zoomViewController hide];
        return;
    }
    if ( numberOfTouches >= 3 ){
        NSLog(@"pinch / numtouches >= 3");
        [zoomViewController hide];
        return;
    }
    if ( ![zoomViewController isVisible] ){
        [zoomViewController show];
    }
    
    CGFloat scale = 1.0 - (self.pinchLastScale - [(UIPinchGestureRecognizer*)sender scale]);
    self.pinchLastScale = [(UIPinchGestureRecognizer*)sender scale];
    CGFloat accum = self.pinchAccumulatedScale * scale;
    if ( accum < 0.25 ) accum = 0.25;
    if ( accum > 40 ) accum = 40;
    self.pinchAccumulatedScale = accum;
    
    bounds.size.width *= self.pinchAccumulatedScale;
    bounds.size.height *= self.pinchAccumulatedScale;
    
    CGPoint xy = [sender locationInView:[sender view]];
    CGPoint topleft = CGPointMake(
                                  xy.x - self.pinchLastPoint.x * bounds.size.width,
                                  xy.y - self.pinchLastPoint.y * bounds.size.height
                                  );
    
    bounds.origin = topleft;
    [self.avc.view setTransform:CGAffineTransformMakeScale(self.pinchAccumulatedScale, self.pinchAccumulatedScale)];
    [self.avc.view setCenter:CGPointMake(topleft.x + bounds.size.width/2, topleft.y + bounds.size.height/2)];
    
    int val = round( self.pinchAccumulatedScale * 100 );
    [zoomViewController setText:val];
    
}

- (void) handleDoubleTap: (id) sender{
    VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
    if ( tgr.numberOfTouches > 1 ) return;

    [self.zoomViewController setText:100];
    
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
    [self.avc.view setTransform:CGAffineTransformMakeScale(1,1)];
    [self.avc.view setCenter:CGPointMake(bounds.size.width/2, bounds.size.height/2)];
    [UIView commitAnimations];
    self.pinchAccumulatedScale = 1.0f;
    //[self handleSingleTap:nil];
    
}

- (void) handleSingleTap: (id) sender{
    if (self.headerController.isPopoverVisible) return;
    VLMTapGestureRecognizer *tgr = (VLMTapGestureRecognizer *)sender;
    if ( tgr.numberOfTouches > 1 ) return;

    
    UIView *h = self.headerController.view;
    [h setUserInteractionEnabled:!h.userInteractionEnabled];

    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [h setAlpha: (h.userInteractionEnabled) ? 1 : 0 ];
                 }
                     completion:nil
     ];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - VLMHeaderDelegate

- (void)updateIndex:(NSInteger)index AndTitle:(NSString *)title{
    NSString *m = @"";
    switch (index) {
        case 0:
            m = @"MODE_GRAPHITE";
            break;
        case 1:
            m = @"MODE_DOTS";
            break;
        case 2:
            m = @"MODE_INK";
            break;
            
        default:
            m = @"MODE_SCRATCH";
            break;
    }

    NSString *s = [NSString stringWithFormat:@"setDrawingMode(%@);", m];
    [self.avc callJS:s];
    
}

- (void)clearScreen{
    [self handleDoubleTap:nil];
    [self.avc callJS:@"clearScreen();"];
}

- (void)screenCapture:(id)screenshotdelegate{
    EJJavaScriptView *jsv = (EJJavaScriptView *)[self.avc view];
    jsv.screenShotDelegate = screenshotdelegate;
    [jsv requestScreenShot];
}

- (void)showPopover{
    NSLog(@"showpop");
    [self.pop show];
    
}

- (void)hidePopover{
    NSLog(@"hidepop");
    [self.pop hide];
}
@end
