//
//  VLMAppDelegate.m
//  Test
//
//  Created by David Lu on 4/1/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMAppDelegate.h"
#import "VLMConstants.h"
#import "VLMMainViewController.h"
#import "UINavigationBar+Fat.h"

@implementation VLMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mainViewController = [[VLMMainViewController alloc] initWithNibName:nil bundle:nil];
    [self.mainViewController.view setBounds:[[UIScreen mainScreen] bounds]];
    
    [self establishAppearanceDefaults];
    
    //self.window.rootViewController = self.mainViewController;
    [self.window setRootViewController:self.mainViewController];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self.mainViewController setPaused:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.mainViewController setPaused:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.mainViewController setPaused:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self.mainViewController setPaused:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark -
#pragma mark appearance

- (void)establishAppearanceDefaults{
    
    // background images
    UIImage *custombgd = NAVIGATION_HEADER_BACKGROUND_IMAGE;
    UIImage *clear = [[UIImage imageNamed:@"clear.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    UIImage *clearfixed = [UIImage imageNamed:@"clear.png"];
    
    // set navbar background
    [[UINavigationBar appearance] setBackgroundImage:custombgd forBarMetrics:UIBarMetricsDefault];

    // set navbar typography
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor,
                                                           [UIColor clearColor], UITextAttributeTextShadowColor,
                                                           [UIFont fontWithName:NAVIGATION_HEADER size:NAVIGATION_HEADER_TITLE_SIZE], UITextAttributeFont,
                                                           nil
                                                           ]];
    
    
    // bar button item background
    [[UIBarButtonItem appearance] setBackgroundImage:clear forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:clear forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    
    // set plain bar button item typography
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:0.2f alpha:1.0f], UITextAttributeTextColor,
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont,
                                                          nil] // end dictionary
                                                forState:UIControlStateNormal
     ];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:1.0f alpha:1.0f], UITextAttributeTextColor,
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont,
                                                          nil] // end dictionary
                                                forState:UIControlStateHighlighted
     ];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:1.0f alpha:1.0f], UITextAttributeTextColor,
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont,
                                                          nil] // end dictionary
                                                forState:UIControlStateHighlighted
     ];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor clearColor], UITextAttributeTextShadowColor,
                                                          [UIColor colorWithWhite:0.2f alpha:0.2f], UITextAttributeTextColor,
                                                          [UIFont fontWithName:@"AmericanTypewriter" size:13.0f], UITextAttributeFont,
                                                          nil] // end dictionary
                                                forState:UIControlStateDisabled
     ];
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, BAR_BUTTON_ITEM_VERTICAL_OFFSET) forBarMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundVerticalPositionAdjustment:BAR_BUTTON_ITEM_VERTICAL_OFFSET-1 forBarMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:clearfixed forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    // interestingly, backbutton needs its own adjustment
    
}

@end
