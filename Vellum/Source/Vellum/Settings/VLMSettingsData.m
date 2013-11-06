//
//  VLMSettings.m
//  Vellum
//
//  Created by David Lu on 11/6/13.
//
//

#import "VLMSettingsData.h"

@implementation VLMSettingsData

@synthesize undoEnabled;

- (id)init {
	if (self = [super init]) {
        [self restoreUndoSettings];
	}
	return self;
}

- (void)restoreUndoSettings{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"undoEnabled";
    if ([defaults objectForKey:key] == nil) {
        [self setUndoEnabled:YES];
        [defaults setObject:[NSNumber numberWithBool:self.undoEnabled] forKey:key];
    } else {
        NSNumber *val = [defaults objectForKey:key];
        [self setUndoEnabled:[val boolValue]];
    }
}

- (void)enableUndo:(BOOL)enabled{
    NSLog(@"enableundo %@", enabled?@"yes":@"no");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = @"undoEnabled";
    [self setUndoEnabled:enabled];
    [defaults setObject:[NSNumber numberWithBool:self.undoEnabled] forKey:key];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:UNDO_SETTING_CHANGED_NOTIFICATION_NAME object:nil];

}



@end
