//
//  VLMToolData.m
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import "VLMToolData.h"

@implementation VLMToolData

@synthesize name;
@synthesize javascriptvalue;
@synthesize selected;
@synthesize enabled;

- (id)init{
    if ( self = [super init] ){
        self.name = @"";
        self.javascriptvalue = @"";
        self.selected = NO;
        self.enabled = YES;
    }
    return self;
}

@end
