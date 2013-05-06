//
//  VLMMainViewController.h
//  Ejecta
//
//  Created by David Lu on 4/21/13.
//
//

#import <UIKit/UIKit.h>
#import "VLMDrawHeaderController.h"

@protocol VLMMenuDelegate <NSObject>

- (void)updateHeader;
- (void)updateHeaderWithTitle:(NSString*)title;
- (void)refreshData;

@end

@interface VLMMainViewController : UIViewController<UIGestureRecognizerDelegate,VLMHeaderDelegate, VLMMenuDelegate>

@end
