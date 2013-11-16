//
//  VLMColorData.h
//  Vellum
//
//  Created by David Lu on 7/31/13.
//
//

#import <Foundation/Foundation.h>
#import "UIColor+Components.h"

@interface VLMColorData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *labeltext;
@property (nonatomic, strong) UIColor *buttoncolor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *rgbaColor;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isSubtractive;

- (id)initWithName:(NSString *)colorname RGBA:(UIColor *)rgba PreMultipliedColor:(UIColor *)bcolor Label:(NSString *)colorlabel Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract;

- (id)initWithName:(NSString *)colorname RGBA:(UIColor *)rgba PreMultipliedColor:(UIColor *)bcolor Label:(NSString *)colorlabel Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract TextColor:(UIColor *)labelColor;

@end
