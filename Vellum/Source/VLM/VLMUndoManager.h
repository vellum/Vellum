//
//  VLMUndoManager.h
//  Vellum
//
//  Created by David Lu on 5/9/13.
//
//

#import <Foundation/Foundation.h>

@interface VLMUndoManager : NSObject

- (id)init;
- (void)saveState:(UIImage *)image;
- (void)restoreState;
- (UIImage *)previousImage;
- (UIImage *)nextImage;
- (BOOL)shouldSaveState;
- (NSInteger)numStates;
- (UIImage *)imageAt:(NSInteger)imageIndex inverted:(BOOL)shouldInvertIndex;
- (void)dropAll;
- (void)dropAllAfterCurrent;

@end
