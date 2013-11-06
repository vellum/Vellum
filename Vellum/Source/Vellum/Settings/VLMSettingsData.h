//
//  VLMSettings.h
//  Vellum
//
//  Created by David Lu on 11/6/13.
//
//

#import <Foundation/Foundation.h>
#define UNDO_SETTING_CHANGED_NOTIFICATION_NAME @"undoSettingChanged"
@interface VLMSettingsData : NSObject

@property (nonatomic) BOOL undoEnabled;
- (void)enableUndo:(BOOL)enabled;

@end
