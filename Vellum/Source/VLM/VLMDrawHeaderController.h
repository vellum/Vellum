//
//  VLMDrawHeaderController.h
//  Ejecta
//
//  Created by David Lu on 4/28/13.
//
//

#import <UIKit/UIKit.h>
#import "EJJavaScriptView.h"

@protocol VLMHeaderDelegate
- (void)updateIndex:(NSInteger)index AndTitle:(NSString *)title;
- (void)clearScreen;
- (void)screenCapture:(id)screenshotdelegate;
- (void)showPopover;
- (void)hidePopover;
@end

@interface VLMDrawHeaderController : UIViewController<UIActionSheetDelegate,VLMScreenShotDelegate>

@property (nonatomic, retain) NSObject<VLMHeaderDelegate> *delegate;
@property (nonatomic) BOOL isPopoverVisible;

- (id) initWithHeadings:(NSArray *)headings;
- (void) setHeadings:(NSArray *)headings;
- (void) nextPage;
- (void) prevPage;

@end
