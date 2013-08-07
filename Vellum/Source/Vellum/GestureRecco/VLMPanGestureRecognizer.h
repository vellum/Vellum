//
//  VLMPanGestureRecognizer.h
//  Ejecta
//
//  Created by David Lu on 5/3/13.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface VLMPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic) BOOL shouldFailWhenNumberOfTouchesExceedsRange;
@property (nonatomic) BOOL shouldFailWhenNumberOfTouchesBelowRange;
@property (nonatomic) NSInteger numberOfTouches;

@end
