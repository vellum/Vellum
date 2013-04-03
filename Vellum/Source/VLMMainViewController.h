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

@interface VLMMainViewController : UIViewController <VLMFlipsideViewControllerDelegate,
    GLKViewDelegate, GLKViewControllerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) GLKView *glView;
@property (strong, nonatomic) GLKViewController *glViewController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;

@property CGPoint startPosition;
@property CGFloat lastScale;
@property CGPoint lastPoint;
@property CGFloat accumulatedScale;

- (IBAction)showInfo:(id)sender;

@end
