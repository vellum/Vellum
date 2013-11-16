//
//  VLMToolData.h
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import <Foundation/Foundation.h>
#define COLOR_INDEX_LOOKUP_KEY @"colorindex_for_%@"

@interface VLMToolData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *javascriptvalue;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isSubtractive;
@property (nonatomic) NSInteger selectedColorIndex;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic) BOOL isBezierRequired;

- (id)init;
- (void)setSelectedColorIndex:(NSInteger)selectedColorIndex andSaveToUserDefaults:(BOOL)shouldSaveToDefaults;
@end
