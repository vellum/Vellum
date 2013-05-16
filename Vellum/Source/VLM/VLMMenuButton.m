//
//  VLMMenuButton.m
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import "VLMMenuButton.h"
@interface VLMMenuButton ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation VLMMenuButton
@synthesize label;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self.label setTextColor:[UIColor blackColor]];
        [self.label setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.label];
        [self setBackgroundImage:[UIImage imageNamed:@"menu_default.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"menu_selected.png"] forState:UIControlStateSelected];
    }
    return self;
}

- (void)setText:(NSString *)text {
    [self.label setText:text];
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
