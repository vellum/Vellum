//
//  VLMColorData.h
//  Vellum
//
//  Created by David Lu on 7/31/13.
//
//

#import <Foundation/Foundation.h>

@interface VLMColorData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *labeltext;
@property (nonatomic) CGFloat opacity;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isSubtractive;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *textColor;

- (id)init;
- (id)initWithName:(NSString *)colorname Color:(UIColor *)buttoncolor Label:(NSString *)colorlabel Opacity:(CGFloat)coloropacity Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract;

- (id)initWithName:(NSString *)colorname Color:(UIColor *)buttoncolor Label:(NSString *)colorlabel Opacity:(CGFloat)coloropacity Enabled:(BOOL)isEnabled Subtractive:(BOOL)shouldSubtract TextColor:(UIColor *)labelColor;

@end
