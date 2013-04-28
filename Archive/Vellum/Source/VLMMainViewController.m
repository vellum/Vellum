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
#import "VLMTouchableView.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface VLMMainViewController ()

@property (strong, nonatomic) GLKView *glView;
@property (strong, nonatomic) GLKViewController *glViewController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;
@property (nonatomic) CGFloat pinchAccumulatedScale;
@property (nonatomic) CGFloat pinchLastScale;
@property (nonatomic) CGPoint pinchLastPoint;
@property (nonatomic) CGPoint drawingTargetPos;
@property (nonatomic) CGPoint drawingCurrentPos;
@property (nonatomic) CGPoint drawingPreviousPos;
@property (nonatomic) BOOL flagNeedsErase;
@property (nonatomic) BOOL flagIsDrawing;
@property (nonatomic) BOOL flagNeedsRestore;
@property (nonatomic, weak) UIImage *screenCapture;

@end


@implementation VLMMainViewController

@synthesize glView;
@synthesize glViewController;
@synthesize zoomViewController;
@synthesize touchCaptureView;
@synthesize pinchLastScale;
@synthesize pinchLastPoint;
@synthesize pinchAccumulatedScale;
@synthesize flagNeedsErase;
@synthesize flagIsDrawing;
@synthesize drawingTargetPos;
@synthesize drawingCurrentPos;
@synthesize drawingPreviousPos;
@synthesize screenCapture;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
    // - - - - - - - - - - - - - - - - - - - - - 
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.flagNeedsErase = YES;
    self.flagIsDrawing = NO;
    self.flagNeedsRestore = NO;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
    // setup to use opengl
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    // gl view
    GLKView *v = [[GLKView alloc] initWithFrame:bounds context:context];
    v.delegate = self;
    v.enableSetNeedsDisplay = YES;
    self.glView = v;
    [self.glView setUserInteractionEnabled:NO];
    
    
    // gl viewcontroller
    GLKViewController *vc = [[GLKViewController alloc] init];
    vc.delegate = self;
    vc.view = v;
    vc.paused = NO;
    vc.preferredFramesPerSecond = 60;
    self.glViewController = vc;

    // add to view tree
    [self.view addSubview:v];

    pinchLastScale = 1.0f;
    pinchAccumulatedScale = 1.0f;
    
    
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
    
    UIPanGestureRecognizer *twoFingerPan;
    UIPinchGestureRecognizer *pinch;

    twoFingerPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerPan:)];
    twoFingerPan.minimumNumberOfTouches = 2;
    twoFingerPan.maximumNumberOfTouches = 2;
    twoFingerPan.delegate = self;
    twoFingerPan.cancelsTouchesInView = NO;


    pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    pinch.cancelsTouchesInView = NO;
    
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

    drawingPreviousPos = drawingCurrentPos = drawingTargetPos = CGPointZero;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UIGestureRecco Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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

- (void)handleOneFingerPan:(id)sender{
    UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)sender;
    if ( pgr.state == UIGestureRecognizerStateFailed ) return;
    
    
    NSLog(@"onefingerpan, %i", [pgr numberOfTouches]);
    CGPoint p = [pgr locationInView:self.glView];
    CGFloat scale = self.glView.contentScaleFactor;
    p.x *= scale; p.y *= scale;
    
    ///*
    if([pgr state] == UIGestureRecognizerStateBegan) {
        self.drawingTargetPos = CGPointMake(p.x, p.y);
        return;
        
    } else if([pgr state] == UIGestureRecognizerStateEnded || [pgr state] == UIGestureRecognizerStateCancelled) {
        self.drawingTargetPos = CGPointMake(p.x, p.y);
        return;
    }
    [self drawLineFrom:CGPointMake(self.drawingTargetPos.x, self.drawingTargetPos.y) To:p];
     //*/
    self.drawingTargetPos = CGPointMake(p.x, p.y);
}

- (void) handlePinch:(id)sender{
    NSLog(@"pinch");
    UIPinchGestureRecognizer *pgr = (UIPinchGestureRecognizer*)sender;
    int numberOfTouches = [pgr numberOfTouches];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    
    if([pgr state] == UIGestureRecognizerStateBegan) {
        
        self.pinchLastScale = 1.0;
        self.pinchLastPoint = [sender locationInView:self.glView];
        self.pinchLastPoint = CGPointMake(self.pinchLastPoint.x/bounds.size.width, self.pinchLastPoint.y/bounds.size.height); // this is now a percentage value
        //NSLog(@"pinch began");
        [self.zoomViewController show];
        return;
        
    } else if([pgr state] == UIGestureRecognizerStateEnded) {
        
        //NSLog(@"pinch ended");
        [self.zoomViewController hide];
        return;
        
    }
    if ( numberOfTouches == 1 ) {
        //NSLog(@"just one touch");
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
    
                                                                /*
                                                                 NSLog(@"anchor( %f, %f ), scale( %f ), scaledbounds( %f, %f ), pinchanchor( %f, %f ), topleft( %f, %f )",
                                                                 self.lastPoint.x, self.lastPoint.y,
                                                                 self.accumulatedScale,
                                                                 bounds.size.width, bounds.size.height,
                                                                 xy.x, xy.y,
                                                                 topleft.x, topleft.y);
                                                                 */
    bounds.origin = topleft;
    [self.glView setTransform:CGAffineTransformMakeScale(self.pinchAccumulatedScale, self.pinchAccumulatedScale)];
    [self.glView setCenter:CGPointMake(topleft.x + bounds.size.width/2, topleft.y + bounds.size.height/2)];
    
    int val = round( self.pinchAccumulatedScale * 100 );
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
    
    self.pinchAccumulatedScale = 1.0f;

}



#pragma mark - GLKViewController Delegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller{
    if (self.flagIsDrawing){

        self.drawingPreviousPos = self.drawingCurrentPos;
        
        CGPoint a = self.drawingCurrentPos;
        CGPoint b = self.drawingTargetPos;
        
        a.x += ( b.x - a.x ) * 0.5f;
        a.y += ( b.y - a.y ) * 0.5f;
        
        self.drawingCurrentPos = a;
        NSLog(@"%f,%f", a.x, a.y);
        double distance = sqrt(pow((b.x - a.x), 2.0) + pow((b.y - a.y), 2.0));
        [self drawLineFrom:self.drawingPreviousPos To:self.drawingCurrentPos];

        [self.glView setNeedsDisplay];
        
        if ( distance < 0.001f ) self.flagIsDrawing = NO;
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //NSLog(@"in glkView:drawInRect:");
    if ( self.flagNeedsErase ){
        self.flagNeedsErase = NO;
        glClearColor( 242.0f/255.0f, 242.0f/255.0f, 232.0f/255.0f, 1.0 );
        glClear(GL_COLOR_BUFFER_BIT);
    }
    if ( self.flagNeedsRestore ){
        
        NSLog(@"needs restore");
        if ( self.screenCapture != nil ){
            
            NSLog(@"hihihihihih");
            NSError *error;
            GLKTextureInfo *ti =[GLKTextureLoader textureWithCGImage:self.screenCapture.CGImage options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft] error:&error];
            if (error) {
                NSLog(@"Error loading texture from image: %@",error);
            } else {
                
                TexturedQuad newQuad;
                newQuad.bl.geometryVertex = CGPointMake(0, 0);
                newQuad.br.geometryVertex = CGPointMake(ti.width, 0);
                newQuad.tl.geometryVertex = CGPointMake(0, ti.height);
                newQuad.tr.geometryVertex = CGPointMake(ti.width, ti.height);
                
                newQuad.bl.textureVertex = CGPointMake(0, 0);
                newQuad.br.textureVertex = CGPointMake(1, 0);
                newQuad.tl.textureVertex = CGPointMake(0, 1);
                newQuad.tr.textureVertex = CGPointMake(1, 1);
                
                
                GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
                effect.useConstantColor = YES;
                effect.constantColor = GLKVector4Make(0, 0, 0, 1);
                
                effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, self.glView.drawableWidth, self.glView.drawableHeight, 0, -2, 2);
                CGFloat scale = self.glView.contentScaleFactor;	// need scale to handle Retina
                
                
                // 1
                effect.texture2d0.name = ti.name;
                effect.texture2d0.enabled = YES;
                
                // 2
                [effect prepareToDraw];
                
                // 3
                glEnableVertexAttribArray(GLKVertexAttribPosition);
                glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
                
                // 4
                long offset = (long)&newQuad;
                glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
                glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
                
                // 5    
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                
            }

        }
    }
}

- (void) drawLineFrom:(CGPoint)a To:(CGPoint)b{
    // test codes
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

    [self.glView setNeedsDisplay];
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
        NSLog(@"save");
        self.screenCapture = [self.glView snapshot];
        
    } else {
        NSLog(@"restore");
        self.flagNeedsRestore = YES;
        // also add something to redraw everything that was on screen previously
        
    }
}

#pragma mark - VLMTouchDelegate

- (void)singleFingerPanBegan:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.glView];
    self.drawingTargetPos = CGPointMake(p.x, p.y);
    self.drawingCurrentPos = CGPointMake(p.x, p.y);
    self.drawingPreviousPos = CGPointMake(p.x, p.y);
    self.flagIsDrawing = YES;
    NSLog(@"singleFingerPanBegan: %f, %f", p.x, p.y);
}

- (void)singleFingerPanChanged:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.glView];
    //[self drawLineFrom:CGPointMake(self.drawingTargetPos.x, self.drawingTargetPos.y) To:p];
    self.drawingTargetPos = CGPointMake(p.x, p.y);
    self.flagIsDrawing = YES;
    NSLog(@"singleFingerPanChanged: %f, %f", p.x, p.y);
}

- (void)singleFingerPanEnded:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.glView];
    self.drawingTargetPos = CGPointMake(p.x, p.y);
    self.flagIsDrawing = NO;
    NSLog(@"singleFingerPanEnded: %f, %f", p.x, p.y);
}

@end
