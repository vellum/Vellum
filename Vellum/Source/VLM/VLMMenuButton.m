//
//  VLMMenuButton.m
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import "VLMMenuButton.h"
@interface VLMMenuButton()
@property (nonatomic,strong) UILabel *label;
@end

@implementation VLMMenuButton
@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        
        [self setBackgroundImage:[UIImage imageNamed:@"menu_default.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"menu_selected.png"] forState:UIControlStateSelected];
        //[self setBackgroundImage:[UIImage imageNamed:@"menu_highlighted.png"] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)setText:(NSString *)text{
    label.text = text;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
