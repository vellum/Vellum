#import <UIKit/UIKit.h>
#import "EJAppViewController.h"
#import "VLMSettingsData.h"

@class VLMMainViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, strong) VLMSettingsData *settings;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) VLMMainViewController *mainViewController;
+ (BOOL)isUndoCapable;
@end
