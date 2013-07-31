//
//  VLMCircleButton.h
//  Vellum
//
//  Created by David Lu on 7/29/13.
//
//

#import <UIKit/UIKit.h>
#import "VLMToolData.h"

@interface VLMCircleButton : UIButton

- (void)show;
- (void)hide;
- (void)showWithDelay:(CGFloat)delay;
- (void)hideWithDelay:(CGFloat)delay;
- (void)setText:(NSString*)text;
- (void)setTool:(VLMToolData *)tool;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
@end
