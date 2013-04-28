//
//  VLMToolViewController.h
//  Test
//
//  Created by David Lu on 4/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VLMToolViewController;

@protocol VLMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(VLMToolViewController *)controller;
@end


@interface VLMToolViewController : UIViewController
@property (weak, nonatomic) id <VLMFlipsideViewControllerDelegate> delegate;
- (void)done:(id)sender;
@end
