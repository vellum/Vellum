//
//  VLMColorData.m
//  Vellum
//
//  Created by David Lu on 7/31/13.
//
//

#import "VLMColorData.h"

@implementation VLMColorData

@synthesize name;
@synthesize labeltext;
@synthesize opacity;
@synthesize enabled;
@synthesize isSubtractive;

- (id)init {
	if (self = [super init]) {
		[self setName:@"black"];
		[self setLabeltext:@"0"];
		[self setOpacity:1];
		[self setEnabled:YES];
	}
	return self;
}

- (id)initWithName:(NSString *)colorname Label:(NSString *)colorlabel Opacity:(CGFloat)coloropacity Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract {
	if (self = [super init]) {
		[self setName:colorname];
		[self setLabeltext:colorlabel];
		[self setOpacity:coloropacity];
		[self setEnabled:isEnabled];
		[self setIsSubtractive:shouldSubtract];
	}
	return self;
}

@end
