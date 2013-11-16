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
@synthesize color;
@synthesize textColor;

- (id)init {
	if (self = [super init]) {
		[self setName:@"black"];
		[self setLabeltext:@"0"];
		[self setOpacity:1];
		[self setEnabled:YES];
        [self setColor:[UIColor clearColor]];
        [self setTextColor:[UIColor whiteColor]];
	}
	return self;
}

- (id)initWithName:(NSString *)colorname Color:(UIColor *)buttoncolor Label:(NSString *)colorlabel Opacity:(CGFloat)coloropacity Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract {
	if (self = [super init]) {
        [self setColor:buttoncolor];
		[self setName:colorname];
		[self setLabeltext:colorlabel];
		[self setOpacity:coloropacity];
		[self setEnabled:isEnabled];
		[self setIsSubtractive:shouldSubtract];
        [self setTextColor:[UIColor whiteColor]];

	}
	return self;
}

- (id)initWithName:(NSString *)colorname Color:(UIColor *)buttoncolor Label:(NSString *)colorlabel Opacity:(CGFloat)coloropacity Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract TextColor:(UIColor *)labelColor{
    if ( self = [super init] ){
        [self setColor:buttoncolor];
		[self setName:colorname];
		[self setLabeltext:colorlabel];
		[self setOpacity:coloropacity];
		[self setEnabled:isEnabled];
		[self setIsSubtractive:shouldSubtract];
        [self setTextColor:labelColor];

    }
    return self;
}

@end
