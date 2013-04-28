//
//  CAEAGLLayer+David.m
//  Vellum
//
//  Created by David Lu on 4/26/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "CAEAGLLayer+David.h"

@implementation CAEAGLLayer (David)


// this lets us draw above what has already been drawn on screen
- (NSDictionary*) drawableProperties
{
    return @{kEAGLDrawablePropertyRetainedBacking : @(YES)};
}

@end
