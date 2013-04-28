//
//  VLMTouchableView.h
//  Vellum
//
//  Created by David Lu on 4/4/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//
//  this class looks at raw touch events and reports single pan "draw" events to a delegate.
// (this requires a level of nuance that i wasn't able to coax from a custom uigesturerecognizer)


#import <UIKit/UIKit.h>

@protocol VLMTouchDelegate
- (void)singleFingerPanBegan:(UITouch*)touch;
- (void)singleFingerPanChanged:(UITouch*)touch;
- (void)singleFingerPanEnded:(UITouch*)touch;
@end

@interface VLMTouchableView : UIView

@property (weak, nonatomic) id <VLMTouchDelegate> delegate;
@property (nonatomic) BOOL enabled;
@end
