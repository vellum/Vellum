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
        
        CGFloat margin = 25;
        CGFloat width = 320-margin*2;
        CGFloat height = 586.0f/320.0f*width;
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        
        UIView *placeholder = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, width, height)];
        [placeholder setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
        [self.contentView addSubview:placeholder];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, placeholder.frame.size.width, placeholder.frame.size.height)];
        [placeholder addSubview:iv];
        [placeholder setUserInteractionEnabled:NO];
        [self setContentImageView:iv];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //[super setSelected:selected animated:animated];

    // Configuqre the view for the selected state
}


- (void)setContentImage:(NSString*)imageName{
    if ( [imageName isEqualToString:self.path] ) return;
    UIImage *image = [UIImage imageNamed:imageName];
    [self.contentImageView setImage:image];
//    [self.contentImageView setAlpha:1.0f];
}


@end
