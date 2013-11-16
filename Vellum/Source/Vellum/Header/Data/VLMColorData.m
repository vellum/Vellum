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
@synthesize enabled;
@synthesize isSubtractive;
@synthesize buttoncolor;
@synthesize textColor;
@synthesize rgbaColor;


- (id)initWithName:(NSString *)colorname RGBA:(UIColor *)rgba PreMultipliedColor:(UIColor *)bcolor Label:(NSString *)colorlabel  Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract{
    if ( self = [super init] ){
        [self setButtoncolor:bcolor];
		[self setName:colorname];
		[self setLabeltext:colorlabel];
		[self setEnabled:isEnabled];
		[self setIsSubtractive:shouldSubtract];
        [self setTextColor:[UIColor whiteColor]];
        [self setRgbaColor:rgba];
    }
    return self;
}

- (id)initWithName:(NSString *)colorname RGBA:(UIColor *)rgba PreMultipliedColor:(UIColor *)bcolor Label:(NSString *)colorlabel Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract TextColor:(UIColor *)labelColor{
    if ( self = [super init] ){
        [self setButtoncolor:bcolor];
		[self setName:colorname];
		[self setLabeltext:colorlabel];
		[self setEnabled:isEnabled];
		[self setIsSubtractive:shouldSubtract];
        [self setTextColor:labelColor];
        [self setRgbaColor:rgba];
    }
    return self;
}

@end
