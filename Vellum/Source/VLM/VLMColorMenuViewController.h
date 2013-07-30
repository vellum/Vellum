//
//  VLMColorMenuViewController.h
//  Vellum
//
//  Created by David Lu on 7/28/13.
//
//

#import <UIKit/UIKit.h>

@interface VLMColorMenuViewController : UIViewController
- (void)hide;
- (void)show;
- (void)update;
- (BOOL)isOpen;
- (void)singleTapToggle;
- (BOOL)isVisible;
- (void)wake;
@end
