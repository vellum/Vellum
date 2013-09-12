//
//  VLMMainViewController.h
//  Ejecta
//
//  Created by David Lu on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "VLMDrawHeaderController.h"
#import "VLMFlipViewController.h"

@protocol VLMMenuDelegate <NSObject>
- (void)updateHeader;
- (void)updateHeaderWithTitle:(NSString *)title;
- (void)refreshData;
- (void)showColorMenu;
- (void)hideColorMenu;
- (void)updateColorMenu;
- (BOOL)isColorMenuOpen;
@end

@class EJAppViewController;

@interface VLMMainViewController : UIViewController <UIGestureRecognizerDelegate, VLMHeaderDelegate, VLMMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VLMFlipsideViewControllerDelegate, VLMScreenShotDelegate>
- (id)initWithEJAppViewController:(EJAppViewController *)appViewController;
- (void)updateUndoCount:(NSInteger)count;
- (void)updateUndoIndex:(NSInteger)index;
- (void)saveStateBeforeTerminating;
- (void)saveStateInBackground;
- (void)hideStatusBarIfNeeded;

@end
