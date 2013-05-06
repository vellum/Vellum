//
//  VLMMenuItem.m
//  Ejecta
//
//  Created by David Lu on 5/5/13.
//
//

#import "VLMMenuItem.h"
@interface VLMMenuItem ()
@property (nonatomic) UIColor *selectedcolor;
@property (nonatomic) UIColor *defaultcolor;
@property (nonatomic,strong) UIView *back;
@property (nonatomic,strong) UIButton *clearbutton;
@property (nonatomic,strong) UILabel *biglabel;
@property BOOL amSelected;
@end

@implementation VLMMenuItem
@synthesize selectedcolor;
@synthesize defaultcolor;
@synthesize back;
@synthesize clearbutton;
@synthesize biglabel;
@synthesize amSelected;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        amSelected = NO;
        UIColor *a = [UIColor colorWithHue:67.0f/360.0f saturation:0.08f brightness:0.9f alpha:1.0f];

        UIColor *b = [UIColor colorWithHue:177.0f/360.0f saturation:0.20f brightness:0.87f alpha:1.0f];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];

        [self addSubview:label];
        
        UIButton *button = [[UIButton alloc] initWithFrame:label.frame];
        [button setBackgroundImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"clear50.png"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
        
        self.clearbutton = button;
        
        self.selectedcolor = a;
        self.defaultcolor = b;
        self.backgroundColor = b;
        self.biglabel = label;
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setSelected:(BOOL)isSelected{
    amSelected = isSelected;
    if (isSelected){
        self.backgroundColor = self.selectedcolor;
    } else {
        self.backgroundColor = self.defaultcolor;
    }
    // call out
}

- (void)setText:(NSString *)text{
    self.biglabel.text = text;
}

- (void)tapped:(id)sender{
    
}
@end
