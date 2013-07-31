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
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIView *shade;
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
@synthesize label;
@synthesize labelhead;
@synthesize back;
@synthesize image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        //[self.layer setCornerRadius:frame.size.width/2.0f];
        [self setAutoresizesSubviews:NO];
        [self setClipsToBounds:YES];
        [self setOriginalRect:frame];
        [self setAdjustsImageWhenHighlighted:NO];
        
        [self setBack:[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.back setAutoresizesSubviews:NO];
        [self.back setUserInteractionEnabled:NO];
        [self.back setBackgroundColor:[UIColor clearColor]];
        [self addSubview:back];

        [self setImage:[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.image setImage:[UIImage imageNamed:@"circlebutton.png"]];
        [self.back addSubview:self.image];

        [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor blackColor]];
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self.label setNumberOfLines:2];
        [self.label setUserInteractionEnabled:NO];
        [self.back addSubview:self.label];
        
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") && NSClassFromString(@"NSMutableAttributedString")){
        } else {
            [self setLabelhead:[[UILabel alloc] initWithFrame:CGRectMake(0, 11, frame.size.width, frame.size.height/2.0f)]];
            [self.labelhead setFont:[UIFont fontWithName:@"Helvetica-Bold" size:9.0f]];
            [self.labelhead setTextAlignment:NSTextAlignmentCenter];
            [self.labelhead setTextColor:[UIColor blackColor]];
            [self.labelhead setBackgroundColor:[UIColor clearColor]];
            [self.labelhead setNumberOfLines:1];
            
            [self setLabeltext:[[UILabel alloc] initWithFrame:CGRectMake(0, 25, frame.size.width, frame.size.height/2.0f)]];
            [self.labeltext setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0f]];
            [self.labeltext setTextAlignment:NSTextAlignmentCenter];
            [self.labeltext setTextColor:[UIColor blackColor]];
            [self.labeltext setBackgroundColor:[UIColor clearColor]];
            [self.labeltext setNumberOfLines:1];

            [self.back addSubview:self.labeltext];
            [self.back addSubview:self.labelhead];
        }


        [self setShade:[[UIView alloc] initWithFrame:CGRectMake((frame.size.width-60.0f)/2.0f, (frame.size.height-60.0f)/2.0f, 60.0f, 60.0f)]];
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
    [self.layer setCornerRadius:self.frame.size.width/2.0f];
    [UIView animateWithDuration:ANIMATION_DURATION*2
                          delay:delay
                        options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setFrame:self.originalRect];
                     }
     
                     completion:^(BOOL finished) {
                         [self.layer setCornerRadius:0.0f];
                     }
     
     ];
}

- (void)hideWithDelay:(CGFloat)delay{
    [self.layer setCornerRadius:self.frame.size.width/2.0f];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:delay
                        options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self setFrame:CGRectMake(originalRect.origin.x + originalRect.size.width/2.0f, originalRect.size.height/2.0f, 0.0f, 0.0f)];
                     }
                     completion:^(BOOL finished) {
                         [self.layer setCornerRadius:0.0f];
                     }
     
     ];

}


-(void)setHighlighted:(BOOL)highlighted
{
    NSLog(@"sethighlighted");
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

- (void)setSelected:(BOOL)selected{
    if ( selected){
        [self.image setImage:[UIImage imageNamed:@"circlebutton_selected.png"]];
        [self.label setTextColor:[UIColor whiteColor]];
        if (self.labelhead != nil){
            [self.labelhead setTextColor:[UIColor whiteColor]];
            [self.labeltext setTextColor:[UIColor whiteColor]];
        }
    } else {
        [self.image setImage:[UIImage imageNamed:@"circlebutton.png"]];
        [self.label setTextColor:[UIColor blackColor]];
        if (self.labelhead != nil){
            [self.labelhead setTextColor:[UIColor blackColor]];
            [self.labeltext setTextColor:[UIColor blackColor]];
        }
    }
    [super setSelected:selected];
}
@end
