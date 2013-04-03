//
//  VLMMainViewController.m
//  Test
//
//  Created by David Lu on 4/1/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMMainViewController.h"
#import "VLMConstants.h"
#import "UINavigationBar+Fat.h"
#import "VLMToolViewController.h"

@interface VLMMainViewController ()

@end

@implementation VLMMainViewController

@synthesize glView;
@synthesize glViewController;
@synthesize touchCaptureView;
@synthesize startPosition;
@synthesize lastScale;
@synthesize lastPoint;
@synthesize accumulatedScale;
@synthesize zoomViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // - - - - - - - - - - - - - - - - - - - - - 
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
    // setup to use opengl
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // gl view
    GLKView *v = [[GLKView alloc] initWithFrame:bounds context:context];
    v.delegate = self;
    self.glView = v;
    
    // gl viewcontroller
    GLKViewController *vc = [[GLKViewController alloc] init];
    vc.delegate = self;
    vc.view = v;
    vc.paused = NO;
    self.glViewController = vc;

    // add to view tree
    [self.view addSubview:v];

    startPosition = v.center;
    lastScale = 1.0f;
    accumulatedScale = 1.0f;
    
    // - - - - - - - - - - - - - - - - - - - - -

    // add zoom indicator
    VLMZoomViewController *z = [[VLMZoomViewController alloc] init];
    [self.view addSubview:z.view];
    self.zoomViewController = z;

    // - - - - - - - - - - - - - - - - - - - - -
    
    // add touch capture layer
    UIView *t = [[UIView alloc] initWithFrame:bounds];
    [self.view addSubview:t];
    self.touchCaptureView = t;
    
    UIPanGestureRecognizer *twoFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.maximumNumberOfTouches = 2;
    twoFingerPan.delegate = self;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    
    [t addGestureRecognizer:pinch];
    [t addGestureRecognizer:twoFingerPan];
    [t addGestureRecognizer:doubleTap];
    
    // - - - - - - - - - - - - - - - - - - - - -

    UIButton *info = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect buttonRect = info.frame;
    buttonRect.origin.x = bounds.size.width - 40;
    buttonRect.origin.y = bounds.size.height - 40;
    [info setFrame:buttonRect];
    [info addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [info setEnabled:YES];
    [self.view addSubview:info];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecco Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTwoFingerPan:(id)sender{
    //NSLog(@"pan");

    
    CGPoint p = [(UIPanGestureRecognizer *)sender translationInView:self.touchCaptureView];
    //NSLog(@"translation: %f, %f", p.x, p.y);

    [sender setTranslation:CGPointZero inView:self.touchCaptureView];
    CGPoint c = self.glView.center;
    c.x += p.x; c.y += p.y;
    
    [self.glView setCenter:c];
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
    } else if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded ||
              [(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateCancelled) {
        NSLog(@"pan ended");
    }
    
}


- (void) handlePinch:(id)sender{
    //NSLog(@"pinch");
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {

        self.lastScale = 1.0;
        self.lastPoint = [sender locationInView:self.glView];
        self.lastPoint = CGPointMake(self.lastPoint.x/bounds.size.width, self.lastPoint.y/bounds.size.height); // this is now a percentage value
        
        NSLog(@"pinch began");
        [self.zoomViewController show];
    } else if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        NSLog(@"pinch ended");
        [self.zoomViewController hide];
    }
    
    CGFloat scale = 1.0 - (self.lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    self.lastScale = [(UIPinchGestureRecognizer*)sender scale];
    CGFloat accum = self.accumulatedScale * scale;
    if ( accum < 0.25 ) accum = 0.25;
    if ( accum > 40 ) accum = 40;
    self.accumulatedScale = accum;

    bounds.size.width *= self.accumulatedScale;
    bounds.size.height *= self.accumulatedScale;
    
    CGPoint xy = [sender locationInView:[sender view]];
    CGPoint topleft = CGPointMake(
                                  xy.x - self.lastPoint.x * bounds.size.width,
                                  xy.y - self.lastPoint.y * bounds.size.height
                                  );
    
    /*
    NSLog(@"anchor( %f, %f ), scale( %f ), scaledbounds( %f, %f ), pinchanchor( %f, %f ), topleft( %f, %f )",
          self.lastPoint.x, self.lastPoint.y,
          self.accumulatedScale,
          bounds.size.width, bounds.size.height,
          xy.x, xy.y,
          topleft.x, topleft.y);
     */
    bounds.origin = topleft;
    [self.glView setTransform:CGAffineTransformMakeScale(self.accumulatedScale, self.accumulatedScale)];
    [self.glView setCenter:CGPointMake(topleft.x + bounds.size.width/2, topleft.y + bounds.size.height/2)];
    
    int val = round( self.accumulatedScale * 100 );
    NSLog(@"%i", val );
    [zoomViewController setText:val];
    
}

- (void) handleDoubleTap: (id) sender{
    NSLog(@"doubletap");
    
    CGRect bounds = [[UIScreen mainScreen] bounds];

    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2];
    [self.glView setTransform:CGAffineTransformMakeScale(1,1)];
    [self.glView setCenter:CGPointMake(bounds.size.width/2, bounds.size.height/2)];
    [UIView commitAnimations];

}

#pragma mark - GLKViewController Delegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
      //NSLog(@"in glkViewControllerUpdate");
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //NSLog(@"in glkView:drawInRect:");
    glClearColor( 0.75, 0.75, 0.75, 1.0 );
    glClear(GL_COLOR_BUFFER_BIT);
}


#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(VLMToolViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(id)sender
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        VLMToolViewController *controller = [[VLMToolViewController alloc] init];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [navController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
        
        [self presentModalViewController:navController animated:YES];
        
    } else {
        /*
        if (!self.flipsidePopoverController) {
            VLMFlipsideViewController *controller = [[VLMFlipsideViewController alloc] initWithNibName:nil bundle:nil];
            controller.delegate = self;
            
            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
//            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
         */
    }
}



@end
