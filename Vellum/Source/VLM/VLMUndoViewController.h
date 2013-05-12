//
//  VLMUndoViewController.h
//  Vellum
//
//  Created by David Lu on 5/11/13.
//
//

#import <UIKit/UIKit.h>

@interface VLMUndoViewController : UIViewController
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger numStates;

- (void)show;
- (void)hide;
- (BOOL)isVisible;
- (void)update;
@end
