//
//  VLMFlipViewController.h
//  Vellum
//
//  Created by David Lu on 6/13/13.
//
//

#import <UIKit/UIKit.h>
#import "UINavigationBar+Fat.h"


@class VLMFlipViewController;

@protocol VLMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(VLMFlipViewController *)controller;
@end



@interface VLMFlipViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) id <VLMFlipsideViewControllerDelegate> delegate;

@end
