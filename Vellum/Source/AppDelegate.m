
#import "AppDelegate.h"
#import "VLMMainViewController.h"
#import "GAI.h"

@implementation AppDelegate
@synthesize window=_window;
@synthesize mainViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Optionally set the idle timer disabled, this prevents the device from sleep when
    // not being interacted with by touch. ie. games with motion control.
    [application setIdleTimerDisabled:YES];
    
    VLMMainViewController *vc = [[VLMMainViewController alloc] init];
    [self setMainViewController:vc];
    [self.window setRootViewController:vc];
    
    
    // google
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    /*
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    */
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-41031955-1"];
    
    return YES;
}

@end
