//
//  VLMOpaButton.h
//  Vellum
//
//  Created by David Lu on 7/25/13.
//
//

#import <UIKit/UIKit.h>

@interface VLMOpaButton : UIButton

- (void)show;
- (void)hide;

- (void)showNoAnimation;
- (void)hideNoAnimation;

-(void)shiftY;
-(void)open;
@end
