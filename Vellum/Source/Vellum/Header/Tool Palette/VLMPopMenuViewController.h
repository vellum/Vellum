//
//  VLMPopMenuViewController.h
//  Ejecta
//
//  Created by David Lu on 5/5/13.
//
//

#import <UIKit/UIKit.h>
#import "VLMMainViewController.h"

@interface VLMPopMenuViewController : UIViewController
@property (nonatomic, strong) id <VLMMenuDelegate> delegate;

- (void)hide;
- (void)show;
- (void)updatebuttons;
@end
