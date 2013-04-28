
#import "AppDelegate.h"
#import "VLMMainViewController.h"

@implementation AppDelegate
@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	// Optionally set the idle timer disabled, this prevents the device from sleep when
	// not being interacted with by touch. ie. games with motion control.
	application.idleTimerDisabled = YES;
    VLMMainViewController *vc = [[VLMMainViewController alloc] init];
    window.rootViewController = vc;
	[vc release];
	
    return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	window.rootViewController = nil;
	[window release];
    [super dealloc];
}


@end
