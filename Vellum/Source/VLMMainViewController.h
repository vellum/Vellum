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
#import "VLMAbstractBrush.h"
#import "VLMTouchableView.h"

@interface VLMMainViewController : UIViewController <VLMFlipsideViewControllerDelegate,
    GLKViewDelegate, GLKViewControllerDelegate, UIGestureRecognizerDelegate, VLMTouchDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) GLKView *glView;
@property (strong, nonatomic) GLKViewController *glViewController;
@property (strong, nonatomic) UIView *touchCaptureView;
@property (strong, nonatomic) VLMZoomViewController *zoomViewController;
@property (strong, nonatomic) VLMAbstractBrush *brush;

@property CGPoint startPosition;
@property CGFloat lastScale;
@property CGPoint lastPoint;


@property CGPoint lastKnownPoint;
@property CGFloat accumulatedScale;
@property BOOL needsErase;

- (IBAction)showInfo:(id)sender;
- (void)setPaused:(BOOL)value;
@end
