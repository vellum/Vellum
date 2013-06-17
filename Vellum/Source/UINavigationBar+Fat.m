//
//  UINavigationBar+Fat.m
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//


@implementation UINavigationBar (Fat)

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width,60.0f);
    return newSize;
    //return size;
}

@end



