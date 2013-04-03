//
//  UINavigationBar+Fat.m
//  Test
//
//  Created by David Lu on 4/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "UINavigationBar+Fat.h"
#import "VLMConstants.h"

@implementation UINavigationBar (Fat)

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,HEADER_HEIGHT);
    return newSize;
}


@end
