//
//  VLMZoomViewController.h
//  Test
//
//  Created by David Lu on 4/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface VLMZoomViewController : UIViewController
{
	UILabel *label;
}

@property(nonatomic,retain) UILabel *label;

- (void)show;
- (void)hide;
- (void)setText:(int)value;

@end
