//
//  VLMTableViewCell.m
//  Vellum
//
//  Created by David Lu on 6/13/13.
//
//

#import "VLMTableViewCell.h"

@interface VLMTableViewCell()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) NSString *path;
@end

@implementation VLMTableViewCell
@synthesize titleLabel;
@synthesize contentImageView;
@synthesize path;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        CGFloat margin = 15;
        UILabel *llll = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, 320-margin*2, 60)];
        [llll setBackgroundColor:[UIColor blackColor]];
        [llll setTextColor:[UIColor whiteColor]];
        [llll setTextAlignment:NSTextAlignmentCenter];
        [llll setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0f]];
        [llll setNumberOfLines:2];
        [self.contentView addSubview:llll];
        [self setTitleLabel:llll];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIView *placeholder = [[UIView alloc] initWithFrame:CGRectMake(margin, 60 + margin, 320-margin*2, 320-margin*2)];
        [placeholder setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
        [self.contentView addSubview:placeholder];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, placeholder.frame.size.width, placeholder.frame.size.height)];
        [placeholder addSubview:iv];
        [placeholder setUserInteractionEnabled:NO];
        [self setContentImageView:iv];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(margin-5, 382, 320-margin*2 + 5*2, 2)];
        [line setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
        [line setUserInteractionEnabled:NO];
        [self.contentView addSubview:line];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configuqre the view for the selected state
}

- (void)setTitleText:(NSString *)text{
    [self.titleLabel setText:text];
}

- (void)setContentImage:(NSString*)imageName{
    if ( [imageName isEqualToString:self.path] ) return;
    UIImage *image = [UIImage imageNamed:imageName];
    [self.contentImageView setImage:image];
//    [self.contentImageView setAlpha:1.0f];
}


@end
