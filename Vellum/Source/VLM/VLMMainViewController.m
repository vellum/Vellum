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
#import "VLMSinglePanGestureRecognizer.h"
#import "EJAppViewController.h"



@interface VLMMainViewController ()

@property (strong, nonatomic) VLMDrawHeaderController *headerController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;
@property (strong, nonatomic) EJAppViewController *avc;
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
    [h setHeadings:[NSArray arrayWithObjects:@"Lines", @"Dots", @"Ink", @"Subtract", nil]];
    [h setDelegate:self];
    
    UIPanGestureRecognizer *twoFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.maximumNumberOfTouches = 2;
    twoFingerPan.delegate = self;
    
    VLMSinglePanGestureRecognizer *oneFingerPan = [[VLMSinglePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
    oneFingerPan.delegate = self;

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    [t addGestureRecognizer:pinch];
    [t addGestureRecognizer:twoFingerPan];
    [t addGestureRecognizer:oneFingerPan];
    [t addGestureRecognizer:doubleTap];
}

#pragma mark - UIGestureRecco Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)handleTwoFingerPan:(id)sender{
    
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)sender;
    if ( [pgr numberOfTouches] == 1 ) {
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

    UIPinchGestureRecognizer *pgr = (UIPinchGestureRecognizer*)sender;
    int numberOfTouches = [pgr numberOfTouches];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if([pgr state] == UIGestureRecognizerStateBegan) {
        self.pinchLastScale = 1.0;
        self.pinchLastPoint = [sender locationInView:self.avc.view];
        self.pinchLastPoint = CGPointMake(self.pinchLastPoint.x/bounds.size.width, self.pinchLastPoint.y/bounds.size.height); // this is now a percentage value
        [self.zoomViewController show];
        return;
    } else if([pgr state] == UIGestureRecognizerStateEnded) {
        [self.zoomViewController hide];
        return;
    }
    if ( numberOfTouches == 1 ) {
        return;
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
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

@end
