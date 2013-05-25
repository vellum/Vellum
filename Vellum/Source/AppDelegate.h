#import <UIKit/UIKit.h>
#import "EJAppViewController.h"
#import "OPPresentatorWindow.h"

@class VLMMainViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, strong) IBOutlet OPPresentatorWindow *window;
@property (nonatomic, strong) VLMMainViewController *mainViewController;

@end
