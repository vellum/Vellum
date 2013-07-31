//
//  VLMCircleButton.m
//  Vellum
//
//  Created by David Lu on 7/29/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "VLMCircleButton.h"
#import "VLMConstants.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface VLMCircleButton ()
@property CGRect originalRect;
@property (nonatomic, strong) UIView *shade;
@property (nonatomic, strong) UIView *outie;
@property (nonatomic, strong) UIView *innie;
// ios 6
@property (nonatomic, strong) UILabel *label;
// ios 5
@property (nonatomic, strong) UILabel *labelhead;
@property (nonatomic, strong) UILabel *labeltext;
@property (nonatomic, strong) UIView *back;
@end

@implementation VLMCircleButton
@synthesize originalRect;
@synthesize shade;
@synthesize outie;
@synthesize innie;
@synthesize label;
@synthesize labelhead;
@synthesize back;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setCornerRadius:frame.size.width/2.0f];
        [self setAutoresizesSubviews:NO];
        [self setClipsToBounds:YES];
        [self setOriginalRect:frame];
        
        [self setBack:[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.back setAutoresizesSubviews:NO];
        [self.back setUserInteractionEnabled:NO];
        [self.back setBackgroundColor:[UIColor clearColor]];
        [self addSubview:back];
        
        CGFloat m = (frame.size.width - 60.0f)/2.0f;
        [self setOutie:[[UIView alloc] initWithFrame:CGRectMake(m, m, 60.0f, 60.0f)]];
        [outie.layer setCornerRadius:30.0f];
        [outie setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
        [self.back addSubview:outie];
        
        [self setInnie: [[UIView alloc] initWithFrame:CGRectMake(m+5, m+5, 50.0f, 50.0f)]];
        [innie.layer setCornerRadius:25.0f];
        [innie setBackgroundColor:[UIColor whiteColor]];
        [self.back addSubview:innie];

        [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor blackColor]];
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setNumberOfLines:2];
        
        [self setLabelhead:[[UILabel alloc] initWithFrame:CGRectMake(0, 11, frame.size.width, frame.size.height/2.0f)]];
        [self.labelhead setFont:[UIFont fontWithName:@"Helvetica-Bold" size:9.0f]];
        [self.labelhead setTextAlignment:NSTextAlignmentCenter];
        [self.labelhead setTextColor:[UIColor blackColor]];
        [self.labelhead setBackgroundColor:[UIColor clearColor]];
        [self.labelhead setNumberOfLines:1];
        //[self.labelhead setText:@"////"];
        
        [self setLabeltext:[[UILabel alloc] initWithFrame:CGRectMake(0, 25, frame.size.width, frame.size.height/2.0f)]];
        [self.labeltext setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
        [self.labeltext setTextAlignment:NSTextAlignmentCenter];
        [self.labeltext setTextColor:[UIColor blackColor]];
        [self.labeltext setBackgroundColor:[UIColor clearColor]];
        [self.labeltext setNumberOfLines:1];
        //[self.labeltext setText:@"////"];
        
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && NSClassFromString(@"NSMutableAttributedString")){
            [self.back addSubview:self.label];
        } else {
            [self.back addSubview:self.labeltext];
            [self.back addSubview:self.labelhead];
        }
        
        [self setShade:[[UIView alloc] initWithFrame:outie.frame]];
        [self.shade setUserInteractionEnabled:NO];
        [self.shade.layer setCornerRadius:30.0f];
        [self.shade setBackgroundColor:[UIColor blackColor]];
        [self.shade setAlpha:0.0f];
        [self addSubview:self.shade];
        
        [self hide];
        [self setBackgroundColor:[UIColor clearColor]];

    }
    return self;
}

- (void)show{
    [self showWithDelay:self.tag * 0.1f];
}

- (void)hide{
    [self hideWithDelay:(self.tag) *0.1f];
}

- (void)showWithDelay:(CGFloat)delay{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay: delay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self setFrame:self.originalRect];
    //[self.back setFrame:CGRectMake(0, 0, originalRect.size.width, originalRect.size.height)];
    [UIView commitAnimations];
}

- (void)hideWithDelay:(CGFloat)delay{
    NSLog(@"hidewithdelay: %f", delay);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay: delay];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [self setFrame:CGRectMake(originalRect.origin.x + originalRect.size.width/2.0f, originalRect.size.height/2.0f, 0.0f, 0.0f)];
    //[self.back setFrame:CGRectMake(-originalRect.size.width/2.0f, 0, originalRect.size.width, originalRect.size.height)];
    [UIView commitAnimations];
}


-(void)setHighlighted:(BOOL)highlighted
{
    // Check if button is going from not highlighted to highlighted
    if(![self isHighlighted] && highlighted) {
        [self.shade setAlpha:0.5f];
    }
    // Check if button is going from highlighted to not highlighted
    else if([self isHighlighted] && !highlighted) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [self.shade setAlpha:0.0f];
        [UIView commitAnimations];
    }
    [super setHighlighted:highlighted];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected];
    CGFloat delay = 0;
    CGFloat duration = 0;//animated ? ANIMATION_DURATION*2 : 0;
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationCurveEaseInOut animations:^{
        if ( selected ){
            [self.label setTextColor:[UIColor whiteColor]];
            [self.labelhead setTextColor:[UIColor whiteColor]];
            [self.labeltext setTextColor:[UIColor whiteColor]];
            [self.outie.layer setBackgroundColor:[UIColor colorWithHue:190.0f/360.0f saturation:0.55f brightness:0.91f alpha:0.5f].CGColor];
            [self.innie.layer setBackgroundColor:[UIColor colorWithHue:190.0f/360.0f saturation:0.55f brightness:0.91f alpha:1.0f].CGColor];
            
        } else {
            [self.label setTextColor:[UIColor blackColor]];
            [self.labelhead setTextColor:[UIColor blackColor]];
            [self.labeltext setTextColor:[UIColor blackColor]];
            [self.outie.layer setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f].CGColor];
            [self.innie.layer setBackgroundColor:[UIColor whiteColor].CGColor];
        }
        
    } completion:nil];
}

- (void)setText:(NSString*)text{
    NSUInteger location = [text rangeOfString:@"\n" options:NSCaseInsensitiveSearch].location;
    if (location != NSNotFound){
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && NSClassFromString(@"NSMutableAttributedString")){
         
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:text];
            [att setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:9.0f]} range:NSMakeRange(0, location)];
            [self.label setAttributedText:att];
            return;
        } else {
            NSString *sub1 = [text substringWithRange:NSMakeRange(0, location)];
            NSString *sub2 = [text substringWithRange:NSMakeRange(location+1, text.length - (location+1))];
            [self.labelhead setText:sub1];
            [self.labeltext setText:sub2];
            return;
        }
    }
    [self.label setText:text];
}

- (void)setTool:(VLMToolData *)tool{
    
}

@end
