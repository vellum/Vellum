//
//  VLMTwoFingerTapGestureRecognizer.h
//  Vellum
//
//  Created by David Lu on 7/5/13.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface VLMTwoFingerTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic) NSInteger numberOfTouches;
@property CGPoint previous1;
@property CGPoint previous2;
@property CGFloat travel1;
@property CGFloat travel2;
@property CGFloat travelthreshold;

@end
