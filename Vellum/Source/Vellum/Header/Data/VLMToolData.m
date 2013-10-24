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
@synthesize isSubtractive;
@synthesize selectedColorIndex;
@synthesize colors;
@synthesize isBezierRequired;

- (id)init {
	if (self = [super init]) {
		[self setName:@""];
		[self setJavascriptvalue:@""];
		[self setSelected:NO];
		[self setEnabled:YES];
		[self setIsSubtractive:NO];
		[self setColors:nil];
		[self setSelectedColorIndex:0];
        [self setIsBezierRequired:NO];
	}
	return self;
}

- (void)setSelectedColorIndex:(NSInteger)colorIndex andSaveToUserDefaults:(BOOL)shouldSaveToDefaults {
	[self setSelectedColorIndex:colorIndex];
	if (shouldSaveToDefaults) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *key = [NSString stringWithFormat:@"%@_colorindex", [self name]];
		[defaults setObject:[NSNumber numberWithInt:colorIndex] forKey:key];
		[defaults synchronize];
	}
}

@end
