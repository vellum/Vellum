#import <UIKit/UIKit.h>
#import "EJAppViewController.h"

@class VLMMainViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) VLMMainViewController *mainViewController;

@end
