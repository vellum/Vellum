#import "AppDelegate.h"
#import "VLMMainViewController.h"
#import "VLMConstants.h"
#import "EJAppViewController.h"
#import "Flurry.h"

@interface AppDelegate ()
@property (strong, nonatomic) EJAppViewController *avc;
@end

@implementation AppDelegate
@synthesize window;
@synthesize mainViewController;
@synthesize avc;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Optionally set the idle timer disabled, this prevents the device from sleep when
	// not being interacted with by touch. ie. games with motion control.
	[application setIdleTimerDisabled:YES];
    
	EJAppViewController *appvc = [[EJAppViewController alloc] init];
	VLMMainViewController *vc = [[VLMMainViewController alloc] initWithEJAppViewController:appvc];
	[self setAvc:appvc];
	[self setMainViewController:vc];
	[window setRootViewController:vc];
	[window insertSubview:appvc.view belowSubview:vc.view];
    
	[window setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"subtlenet.png"]]];
    
#if STYLED_HEADER
	[self establishAppearanceDefaults];
#endif
    
    [Flurry startSession:@"83417d5908b1b9c7eb727c45fdab1b3f"];
    /*
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
    [Flurry setVersion:version];
    
    BOOL isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    BOOL isRetina = NO;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        isRetina = YES;
    }
    NSDictionary *logparams = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:isIpad], @"isTablet",
                       [NSNumber numberWithBool:isRetina], @"isRetina",
                       nil];
    [Flurry logEvent:@"Start" withParameters:logparams];
     */
    
	return YES;
}

#pragma mark -
#pragma mark appearance

- (void)establishAppearanceDefaults {
	// background images
	UIImage *clear = [[UIImage imageNamed:@"clear.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	UIImage *clearfixed = [UIImage imageNamed:@"clear.png"];
    
	// set navbar background
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"gray_header_background.png"] forBarMetrics:UIBarMetricsDefault];
	// interestingly, backbutton needs its own adjustment
	// set navbar typography
	[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                                      [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor,
	                                                      [UIColor clearColor], UITextAttributeTextShadowColor,
	                                                      [UIFont fontWithName:@"Helvetica-Bold" size:18.f], UITextAttributeFont,
	                                                      nil
                                                          ]];
    
    
	// bar button item background
	[[UIBarButtonItem appearance] setBackgroundImage:clear forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setBackgroundImage:clear forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    
	// set plain bar button item typography
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                                      [UIColor clearColor], UITextAttributeTextShadowColor,
	                                                      [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor,
	                                                      [UIFont fontWithName:@"Helvetica-Bold" size:12.0f], UITextAttributeFont,
	                                                      nil] // end dictionary
	                                            forState:UIControlStateNormal
     ];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                                      [UIColor clearColor], UITextAttributeTextShadowColor,
	                                                      [UIColor colorWithWhite:1.0f alpha:1.0f], UITextAttributeTextColor,
	                                                      [UIFont fontWithName:@"Helvetica-Bold" size:12.0f], UITextAttributeFont,
	                                                      nil] // end dictionary
	                                            forState:UIControlStateHighlighted
     ];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                                      [UIColor clearColor], UITextAttributeTextShadowColor,
	                                                      [UIColor colorWithWhite:1.0f alpha:1.0f], UITextAttributeTextColor,
	                                                      [UIFont fontWithName:@"Helvetica-Bold" size:12.0f], UITextAttributeFont,
	                                                      nil] // end dictionary
	                                            forState:UIControlStateHighlighted
     ];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
	                                                      [UIColor clearColor], UITextAttributeTextShadowColor,
	                                                      [UIColor colorWithWhite:0.2f alpha:0.2f], UITextAttributeTextColor,
	                                                      [UIFont fontWithName:@"Helvetica-Bold" size:12.0f], UITextAttributeFont,
	                                                      nil] // end dictionary
	                                            forState:UIControlStateDisabled
     ];
	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:clearfixed forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
#if FAT_HEADER
	NSLog(@"fat header defined");
    
    
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		[[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, BAR_BUTTON_ITEM_VERTICAL_OFFSET) forBarMetrics:UIBarMetricsDefault];
        
		[[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment:BAR_BUTTON_ITEM_VERTICAL_OFFSET forBarMetrics:UIBarMetricsDefault];
	}
	else {
		[[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment:-1.0f forBarMetrics:UIBarMetricsDefault];
	}
#else
	[[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment:-1.0f forBarMetrics:UIBarMetricsDefault];
#endif
}

@end
