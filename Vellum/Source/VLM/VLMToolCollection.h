//
//  VLMToolCollection.h
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import <Foundation/Foundation.h>

@class VLMToolData;

@interface VLMToolCollection : NSObject

@property (nonatomic, strong) NSMutableArray *tools;
@property (nonatomic) NSInteger selectedIndex;

+ (VLMToolCollection *)instance;
- (NSMutableArray *)getEnabledTools;
- (NSInteger)getSelectedEnabledIndex;
- (VLMToolData *)getSelectedToolFromEnabledIndex:(NSInteger)index;
- (BOOL)isSelectedToolSubtractive;
- (BOOL)isToggleable;
@end
