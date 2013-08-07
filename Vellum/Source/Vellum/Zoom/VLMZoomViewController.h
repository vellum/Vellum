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
	CGFloat zoomlevel;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic) CGFloat zoomlevel;

- (void)show;
- (void)hide;
- (void)setText:(int)value;
- (BOOL)isVisible;

@end
