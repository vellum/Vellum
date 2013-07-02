//
//  VLMSectionView.h
//  Vellum
//
//  Created by David Lu on 6/21/13.
//
//

#import <UIKit/UIKit.h>

@interface VLMSectionView : UIView{
    UILabel *headerLabel;
}

@property (nonatomic, strong) UILabel *headerLabel;

- (void)setText:(NSString*)text;
- (void)reset;
- (void)setAttributedText:(NSMutableAttributedString *)text;
+ (CGFloat)expectedViewHeightForText:(NSString *)text;
@end
