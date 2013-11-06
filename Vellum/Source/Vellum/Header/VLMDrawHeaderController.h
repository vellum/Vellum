//
//  VLMDrawHeaderController.h
//  Ejecta
//
//  Created by David Lu on 4/28/13.
//
//

#import <UIKit/UIKit.h>
#import "EJJavaScriptView.h"

@class DDPageControl;

@protocol VLMHeaderDelegate

- (void)updateIndex:(NSInteger)index AndTitle:(NSString *)title;
- (void)clearScreen;
- (void)screenCapture:(id)screenshotdelegate;
- (void)showPopover;
- (void)hidePopover;

- (void)requestUndo;
- (void)requestRedo;

@end

@interface VLMDrawHeaderController : UIViewController <UIActionSheetDelegate, VLMScreenShotDelegate, UIPopoverControllerDelegate>

@property (nonatomic, retain) NSObject <VLMHeaderDelegate> *delegate;
@property (nonatomic) BOOL isPopoverVisible;

- (id)initWithHeadings:(NSArray *)headings;
- (void)setHeadings:(NSArray *)headings;
- (void)setSelectedIndex:(NSInteger)selectedIndex andTitle:(NSString *)title;
- (void)setSelectedIndex:(NSInteger)selectedIndex andTitle:(NSString *)title animated:(BOOL)shouldAnimate;
- (void)nextPage;
- (void)prevPage;
- (void)resetToZero;
- (void)updatePage;
- (void)dismissPopoverController;
- (void)cleanupImagePicker;
- (void)togglePopover;
- (void)showPopover;

- (void)showSubtitleWithText:(NSString *)text;
- (void)hideSubtitle;

- (void)updateUndoIndex:(NSInteger)undoIndex andUndoCount:(NSInteger)undoCount;


@end
