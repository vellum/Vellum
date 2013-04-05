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
@synthesize needsErase;
@synthesize brush;
@synthesize lastKnownPoint;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // - - - - - - - - - - - - - - - - - - - - - 
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.needsErase = YES;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
    // setup to use opengl
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // gl view
    GLKView *v = [[GLKView alloc] initWithFrame:bounds context:context];
    v.delegate = self;
    self.glView = v;
    [self.glView setUserInteractionEnabled:NO];
    
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
    
    self.brush = [[VLMAbstractBrush alloc] initWithSize:CGSizeMake(self.glView.drawableWidth, self.glView.drawableHeight) andScale:self.glView.contentScaleFactor];
    
    // - - - - - - - - - - - - - - - - - - - - -

    // add zoom indicator
    VLMZoomViewController *z = [[VLMZoomViewController alloc] init];
    [self.view addSubview:z.view];
    self.zoomViewController = z;

    // - - - - - - - - - - - - - - - - - - - - -
    
    // add touch capture layer
    VLMTouchableView *t = [[VLMTouchableView alloc] initWithFrame:bounds];
    t.delegate = self;
    [self.view addSubview:t];
    self.touchCaptureView = t;
    
    UIPanGestureRecognizer *twoFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.maximumNumberOfTouches = 2;
    twoFingerPan.delegate = self;
    twoFingerPan.cancelsTouchesInView = YES;
    
    UIPanGestureRecognizer *oneFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOneFingerPan:)];
    oneFingerPan.minimumNumberOfTouches = 1;
    oneFingerPan.maximumNumberOfTouches = 1;
    oneFingerPan.delegate = self;
    //oneFingerPan.cancelsTouchesInView = NO;
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    pinch.cancelsTouchesInView = YES;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    
    //[oneFingerPan requireGestureRecognizerToFail:twoFingerPan];
    
    [t addGestureRecognizer:pinch];
    [t addGestureRecognizer:twoFingerPan];
    //[t addGestureRecognizer:oneFingerPan];
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

    lastKnownPoint = CGPointZero;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIGestureRecco Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleOneFingerPan:(id)sender{
    NSLog(@"1-pan");
    
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *) sender;

    /// THIS IS WRONG
    CGPoint p = [pgr translationInView:self.touchCaptureView];

    if([pgr state] == UIGestureRecognizerStateBegan) {
        self.startPosition = CGPointMake(p.x, p.y);
        [self.brush strokeBegin:p];

    } else if([pgr state] == UIGestureRecognizerStateEnded ||
              [pgr state] == UIGestureRecognizerStateCancelled) {
        p.x += self.startPosition.x;
        p.y += self.startPosition.y;
        [self.brush strokeEnd:p];
        
    } else if([pgr state] == UIGestureRecognizerStateChanged) {
        p.x += self.startPosition.x;
        p.y += self.startPosition.y;
        [self.brush stroke:p];
        
    }
    //[self testDrawing];
    [self.glView setNeedsDisplay];
    //[pgr setTranslation:CGPointZero inView:self.touchCaptureView];
}

- (void)handleTwoFingerPan:(id)sender{

    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)sender;
    NSLog(@"twofingerpan, %i", [pgr numberOfTouches]);

    if ( [pgr numberOfTouches] == 1 ) {
        return;
        
    } else if([pgr state] == UIGestureRecognizerStateBegan) {
        return;

    } else if([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        return;
    
    }
    
    
    CGPoint p = [(UIPanGestureRecognizer *)sender translationInView:self.touchCaptureView];
    [sender setTranslation:CGPointZero inView:self.touchCaptureView];
    CGPoint c = self.glView.center;
    c.x += p.x; c.y += p.y;
    [self.glView setCenter:c];
}

- (void) handlePinch:(id)sender{
    NSLog(@"pinch");
    UIPinchGestureRecognizer *pgr = (UIPinchGestureRecognizer*)sender;
    int numberOfTouches = [pgr numberOfTouches];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if([pgr state] == UIGestureRecognizerStateBegan) {
        
        self.lastScale = 1.0;
        self.lastPoint = [sender locationInView:self.glView];
        self.lastPoint = CGPointMake(self.lastPoint.x/bounds.size.width, self.lastPoint.y/bounds.size.height); // this is now a percentage value
        NSLog(@"pinch began");
        [self.zoomViewController show];
        return;
        
    } else if([pgr state] == UIGestureRecognizerStateEnded) {
        
        NSLog(@"pinch ended");
        [self.zoomViewController hide];
        return;
        
    }
    if ( numberOfTouches == 1 ) {
        NSLog(@"just one touch");
        return;
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
    
    self.accumulatedScale = 1.0f;

}



#pragma mark - GLKViewController Delegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller{
      //NSLog(@"in glkViewControllerUpdate");
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //NSLog(@"in glkView:drawInRect:");
    if ( self.needsErase ){
        self.needsErase = NO;
        glClearColor( 242.0f/255.0f, 242.0f/255.0f, 232.0f/255.0f, 1.0 );
        glClear(GL_COLOR_BUFFER_BIT);
    }


}

- (void) testDrawing{
    // test code
    static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0;
	
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    
    vertexBuffer[0] = 0;
    vertexBuffer[1] = 0;
    vertexBuffer[2] = 100;
    vertexBuffer[3] = 100;
    
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
	effect.useConstantColor = YES;
    effect.constantColor = GLKVector4Make(0, 0, 0, 1);
    
	effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, self.glView.drawableWidth, self.glView.drawableHeight, 0, -2, 2);
	CGFloat scale = self.glView.contentScaleFactor;	// need scale to handle Retina displays
    
    glLineWidth(2.0f * scale);
    
    // Render the vertex array
    [effect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    NSUInteger firstInd = 0;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, &vertexBuffer[firstInd*2]);
    glDrawArrays(GL_LINE_STRIP, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribPosition);

}

- (void) drawLineFrom:(CGPoint)a To:(CGPoint)b{
    // test code
    static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0;
	
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    
    CGFloat s = self.glView.contentScaleFactor;
    vertexBuffer[0] = a.x * s;
    vertexBuffer[1] = a.y * s;
    vertexBuffer[2] = b.x * s;
    vertexBuffer[3] = b.y * s;
    NSLog(@"%f,%f    %f,%f", a.x, a.y, b.x, b.y);
    
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
	effect.useConstantColor = YES;
    effect.constantColor = GLKVector4Make(0, 0, 0, 1);
    
	effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, self.glView.drawableWidth, self.glView.drawableHeight, 0, -2, 2);
	CGFloat scale = self.glView.contentScaleFactor;	// need scale to handle Retina displays
    
    glLineWidth(1.0f * scale);
    
    // Render the vertex array
    [effect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    NSUInteger firstInd = 0;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, &vertexBuffer[firstInd*2]);
    glDrawArrays(GL_LINES, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribPosition);

}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(VLMToolViewController *)controller{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)showInfo:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        VLMToolViewController *controller = [[VLMToolViewController alloc] init];
        controller.delegate = self;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [navController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
        [self presentViewController:navController animated:YES completion:nil];
        
    } else {

        if (!self.flipsidePopoverController) {
            VLMToolViewController *controller = [[VLMToolViewController alloc] init];
            controller.delegate = self;

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            [navController.navigationBar setTitleVerticalPositionAdjustment:HEADER_TITLE_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];

            self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        }
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
//            [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            UIButton *b = (UIButton*)sender;

            [self.flipsidePopoverController presentPopoverFromRect:b.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
    }
}



#pragma mark - Drawing Code

- (void)setPaused:(BOOL)value{
    [self.glViewController setPaused:value];
    if ( value ){
        self.needsErase = YES;
        // also add something to redraw everything that was on screen previously
    }
}

#pragma mark - VLMTouchDelegate

- (void)singleFingerPanBegan:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.glView];
    self.lastKnownPoint = CGPointMake(p.x, p.y);
}
- (void)singleFingerPanChanged:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.glView];
    [self drawLineFrom:CGPointMake(self.lastKnownPoint.x, self.lastKnownPoint.y) To:p];
    self.lastKnownPoint = CGPointMake(p.x, p.y);
}
- (void)singleFingerPanEnded:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.glView];
    [self drawLineFrom:self.lastKnownPoint To:p];
    self.lastKnownPoint = CGPointMake(p.x, p.y);
}

@end
