//
//  VLMTouchableView.h
//  Vellum
//
//  Created by David Lu on 4/4/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol VLMTouchDelegate
- (void)singleFingerPanBegan:(UITouch*)touch;
- (void)singleFingerPanChanged:(UITouch*)touch;
- (void)singleFingerPanEnded:(UITouch*)touch;
@end

@interface VLMTouchableView : UIView

@property (weak, nonatomic) id <VLMTouchDelegate> delegate;

@end
