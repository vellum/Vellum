//
//  VLMPinchGestureRecognizer.h
//  Ejecta
//
//  Created by David Lu on 5/4/13.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface VLMPinchGestureRecognizer : UIPinchGestureRecognizer

@property (nonatomic) NSInteger numberOfTouches;

@end
