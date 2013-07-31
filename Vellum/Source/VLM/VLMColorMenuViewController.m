//
//  VLMColorMenuViewController.m
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import "VLMColorMenuViewController.h"
#import "VLMConstants.h"
#import "VLMCircleButton.h"
#import "VLMScrollView.h"
#import "VLMToolCollection.h"
#import "VLMToolData.h"

@interface VLMColorMenuViewController ()
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIView *outie;
@property (nonatomic, strong) UIView *innie;
@property (nonatomic) BOOL open;
@end

@implementation VLMColorMenuViewController
@synthesize buttons;
@synthesize scrollview;
@synthesize outie;
@synthesize innie;
@synthesize open;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    buttons = [[NSMutableArray alloc] init];

    [self.view setBackgroundColor:[UIColor clearColor]];
    //[self.view setAlpha:0.0f];
    CGFloat winw = [[UIScreen mainScreen] bounds].size.width;

    CGFloat margin = 0.0f;
    CGFloat innermargin = 3.0f;
    CGFloat pad = 1;
    CGFloat buttonsize = 74.0f;
    
    CGPoint topleft;
    topleft = CGPointMake(innermargin, innermargin);
    
    [self.view setFrame:CGRectMake(0.0f, HEADER_HEIGHT + buttonsize + 2*innermargin + 5.0f, winw, buttonsize + margin*2 + innermargin*2)];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view setContentMode:UIViewContentModeCenter];

    NSInteger numbuttons = [[[VLMToolCollection instance] colorlabels] count];

    VLMScrollView *sv = [[VLMScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [sv setContentSize:CGSizeMake(innermargin*2 + numbuttons * (buttonsize+pad), buttonsize+pad)];
    [sv setPagingEnabled:YES];
    

    [sv setBackgroundColor:[UIColor clearColor]];
    [sv setCanCancelContentTouches:YES];
    [sv setAlwaysBounceHorizontal:YES];
    [sv setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [sv setContentMode:UIViewContentModeCenter];
    
    [sv setShowsHorizontalScrollIndicator:NO];
    [sv setShowsVerticalScrollIndicator:NO];
    
    [self setScrollview:sv];
    [self.view addSubview:sv];
    self.scrollview.canCancelContentTouches = YES;
    
    VLMToolCollection *tools = [VLMToolCollection instance];
    for ( int i = 0; i < numbuttons; i++){
        VLMCircleButton *circle = [[VLMCircleButton alloc] initWithFrame:CGRectMake( innermargin + i * (buttonsize+pad), 0, buttonsize+pad, buttonsize+pad)];
        [circle setTag:i];
        [sv addSubview:circle];
        [buttons addObject:circle];
        [circle addTarget:self action:@selector(menuItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        NSString *text = [[tools colorlabels] objectAtIndex:i];
        [circle setText:text];
    }

    innermargin = 10.0f;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(innermargin, self.view.frame.size.height-1, self.view.frame.size.width-innermargin*2, 1.0f)];
    [line setBackgroundColor:[UIColor whiteColor]];
    [line setAlpha:0.75f];
    [line setUserInteractionEnabled:NO];
    [self.view addSubview:line];
    [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [line setContentMode:UIViewContentModeCenter];

    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(innermargin, self.view.frame.size.height, self.view.frame.size.width-innermargin*2, 1.0f)];
    [line2 setBackgroundColor:[UIColor grayColor]];
    [line2 setAlpha:0.05f];
    [line2 setUserInteractionEnabled:NO];
    [self.view addSubview:line2];
    [line2 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [line2 setContentMode:UIViewContentModeCenter];

    [self.view setAlpha:0.0f];
    [self hide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - public ()

- (void)show {
    [self updatebuttonsAnimated:NO];
    [self resetScroll];
    [self setOpen:YES];
    [self.view setUserInteractionEnabled:YES];

    
    CGFloat offx = [self.scrollview contentOffset].x;
    int start = 0;
    for ( int i = 0; i < [self.buttons count]; i++){
        VLMCircleButton *circle = (VLMCircleButton*)[self.buttons objectAtIndex:i];
        if (circle.frame.origin.x-offx<0){
            start = i;
            [circle showWithDelay:0];
        } else {
            [circle showWithDelay:(i-start)*0.1f];
        }
    }

    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self.view setAlpha:1.0f];
    [UIView commitAnimations];
}

- (void)hide {
    [self setOpen:NO];
    
    for (int i = 0; i < [self.buttons count]; i++){
        VLMCircleButton *circle = (VLMCircleButton*)[self.buttons objectAtIndex:i];
        [circle hideWithDelay:0.0f];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [self.view setAlpha:0.0f];
    [UIView commitAnimations];

    /*
     CGPoint offset = [self.scrollview contentOffset];
     NSInteger firstindex = -1;
    for (int i = 0; i < [self.buttons count]; i++){
        VLMCircleMaskedView *circle = (VLMCircleMaskedView*)[self.buttons objectAtIndex:i];
        CGFloat x = circle.frame.origin.x - offset.x;
        if (x > 0 && firstindex==-1){
            firstindex = i;
        }
    }
    NSInteger lastindex = firstindex + (NSInteger)(self.view.frame.size.width/75);
    if ( lastindex > [self.buttons count]-1 ){
        lastindex = [self.buttons count]-1;
    }
    for (int i = [self.buttons count]-1; i>=0; i--){
        CGFloat delay = 0;
        VLMCircleMaskedView *circle = (VLMCircleMaskedView*)[self.buttons objectAtIndex:i];
        delay = (lastindex-i) * 0.025f;
        if ( delay < 0 ) delay = 0;
        [circle hideWithDelay:delay];

    }
     */
    [self.view setUserInteractionEnabled:NO];
}

- (BOOL)isOpen{
    return self.open;
//    return self.view.userInteractionEnabled;
}

- (void)update{
    [self updatebuttonsAnimated:YES];
    [self resetScroll];
}

- (void)singleTapToggle{
    if ( ![self isOpen] ) return;
    if ( [self isVisible] ){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [self.view setAlpha:0.0f];
        [UIView commitAnimations];
        [self.view setUserInteractionEnabled:NO];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [self.view setAlpha:1.0f];
        [UIView commitAnimations];
        [self.view setUserInteractionEnabled:YES];
    }
}

- (BOOL)isVisible{
    if ( self.view.alpha == 1.0f ) return YES;
    return NO;
}

- (void)wake{
    if ( [self isOpen] && ![self isVisible]){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [self.view setAlpha:1.0f];
        [UIView commitAnimations];
        [self.view setUserInteractionEnabled:YES];
    }
}

#pragma mark - private ()

- (void)menuItemTapped:(id)sender {
    VLMCircleButton *mb = (VLMCircleButton *)sender;
    NSInteger tag = mb.tag;
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *selectedtool = (VLMToolData *)[[tools tools] objectAtIndex:[tools selectedIndex]];
    [selectedtool setSelectedColorIndex:tag];
    [self updatebuttonsAnimated:NO];
}

- (void)updatebuttonsAnimated:(BOOL)animated{
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *selectedtool = (VLMToolData *)[[tools tools] objectAtIndex:[tools selectedIndex]];
    NSInteger ind = [selectedtool selectedColorIndex];
    for (int i = 0; i < [self.buttons count]; i++){
        VLMCircleButton *circle = (VLMCircleButton*)[self.buttons objectAtIndex:i];
        [circle setSelected:ind==i animated:animated];
    }
}

- (void)resetScroll{
    NSLog(@"resetscroll");
    VLMToolCollection *tools = [VLMToolCollection instance];
    VLMToolData *selectedtool = (VLMToolData *)[[tools tools] objectAtIndex:[tools selectedIndex]];
    CGFloat page = floorf((selectedtool.selectedColorIndex*75.0f + 75 + 3) / self.scrollview.frame.size.width);
    [self.scrollview scrollRectToVisible:CGRectMake(page*self.scrollview.frame.size.width, 0, self.scrollview.frame.size.width, 1) animated:YES];
}

@end
