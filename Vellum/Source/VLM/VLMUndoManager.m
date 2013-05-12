//
//  VLMUndoManager.m
//  Vellum
//
//  Created by David Lu on 5/9/13.
//
//

#import "VLMUndoManager.h"
#import "VLMUndoState.h"

#define ELAPSED_THRESHOLD 3.0f
#define MAX_UNDO_STATES   4

@interface VLMUndoManager ()
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) NSInteger index;

@end

@implementation VLMUndoManager
@synthesize images;
@synthesize index;

#pragma mark - ()

- (id)init {
    if (self = [super init]) {
        [self setImages:[[NSMutableArray alloc] init]];
        [self setIndex:0];
    } else {
        return nil;
    }
    return self;
}

- (NSInteger)numStates {
    return [self.images count];
}

- (BOOL)shouldSaveState {
    if ([self.images count] == 0) return YES;
    
    VLMUndoState *mostRecentState = (VLMUndoState *)[self.images lastObject];
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    if (current - mostRecentState.timeStamp > ELAPSED_THRESHOLD) {
        return YES;
    }
    
    return NO;
}

- (void)saveState:(UIImage *)image {
    if ([self.images count] > MAX_UNDO_STATES) {
        [self.images removeObjectAtIndex:0];
    }
    VLMUndoState *state = [[VLMUndoState alloc] initWithImage:image];
    [self.images addObject:state];
    [self setIndex:self.images.count-1];
    NSLog(@"count %d", self.images.count);
}

- (void)restoreState {
}

- (UIImage *)imageAt:(NSInteger)imageIndex inverted:(BOOL)shouldInvertIndex {
    NSInteger convertedIndex = imageIndex;
    if (self.images.count == 0) return nil;
    int min = 0;
    int max = self.images.count - 1;
    if ( imageIndex < min || imageIndex > max) return nil;
    
    if (shouldInvertIndex) {
        convertedIndex = max - imageIndex;
    }
    NSLog(@"retrieving image at %d (%d)", imageIndex, convertedIndex);
    VLMUndoState *state = (VLMUndoState *)[self.images objectAtIndex:convertedIndex];
    if ( state == nil ) return nil;
    [self setIndex:convertedIndex];
    return state.image;
}

- (UIImage *)previousImage {
    NSInteger ind = self.index;
    ind--;
    if (ind < 0) {
        ind = 0;
    }
    VLMUndoState *state = (VLMUndoState *)[self.images objectAtIndex:ind];
    [self setIndex:ind];
    return state.image;
}

- (UIImage *)nextImage {
    NSInteger ind = self.index;
    ind++;
    if (ind > [self.images count]) {
        ind = [self.images count] - 1;
    }
    VLMUndoState *state = (VLMUndoState *)[self.images objectAtIndex:ind];
    [self setIndex:ind];
    return state.image;
}

- (void)dropAll {
    [self.images removeAllObjects];
    [self setIndex:0];
}
- (void)dropAllAfterCurrent{
    if ( images.count <= 1 ) {
        [self setIndex:0];
        return;
    }
    int min = self.index+1;
    int max = self.images.count-1;
    int len = max-min;
    if (min < max){
        [self.images removeObjectsInRange:(NSRange){min, len}];
    }
}


@end