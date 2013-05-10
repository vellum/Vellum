//
//  VLMUndoState.m
//  Vellum
//
//  Created by David Lu on 5/9/13.
//
//

#import "VLMUndoState.h"

@interface VLMUndoState()
@end

@implementation VLMUndoState

@synthesize timeStamp;
@synthesize fileName;
@synthesize image;

- (id)init {
    if (self = [super init]) {
        NSString *prefixString = @"undo_";
        NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
        NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
        [self setFileName:uniqueFileName];
        [self setTimeStamp:[[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

- (id)initWithImage:(UIImage *)existingImage {
    if (self = [self init]) {
        [self setImage:existingImage];
    }
    return self;
}

#pragma mark - ()


@end
