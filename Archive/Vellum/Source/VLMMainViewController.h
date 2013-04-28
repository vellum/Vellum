//
//  VLMMainViewController.h
//  Test
//
//  Created by David Lu on 4/1/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
#import "VLMToolViewController.h"
#import "VLMZoomViewController.h"
#import "UINavigationBar+Fat.h"
#import "VLMTouchableView.h"

@interface VLMMainViewController : UIViewController <VLMFlipsideViewControllerDelegate,
    GLKViewDelegate, GLKViewControllerDelegate, UIGestureRecognizerDelegate, VLMTouchDelegate>
- (IBAction)showInfo:(id)sender;
- (void)setPaused:(BOOL)value;

@end
