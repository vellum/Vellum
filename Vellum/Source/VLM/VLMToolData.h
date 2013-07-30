//
//  VLMToolData.h
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import <Foundation/Foundation.h>

@interface VLMToolData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *javascriptvalue;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isSubtractive;
@property (nonatomic) NSInteger selectedColorIndex;
- (id)init;
@end
