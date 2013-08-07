//
//  VLMTapGestureRecognizer.h
//  Ejecta
//
//  Created by David Lu on 5/4/13.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface VLMTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic) NSInteger numberOfTouches;
@property CGPoint previous;
@property CGFloat travel;
@property CGFloat travelthreshold;
@end
