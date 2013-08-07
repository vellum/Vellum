//
//  UINavigationBar+Fat.m
//  ThisVersusThat
//
//  Created by David Lu on 7/24/12.
//  Copyright (c) 2012 NerdGypsy. All rights reserved.
//
#import "VLMConstants.h"

@implementation UINavigationBar (Fat)

- (CGSize)sizeThatFits:(CGSize)size {
#if FAT_HEADER
    CGSize newSize = CGSizeMake(self.frame.size.width,60.0f);
    return newSize;
#else
    return CGSizeMake(self.frame.size.width,44.0f);
#endif
}

@end



