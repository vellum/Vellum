//
//  VLMAbstractBrush.h
//  Vellum
//
//  Created by David Lu on 4/3/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>

#define MAXT	300				// maximum number of lines (adjust these if you want more/less)
#define MAXP	3000			// maximum number of line segments

@interface VLMAbstractBrush : NSObject {
    GLfloat		points[MAXP*2];		// keeps track of all the points for line segments
}

@property CGPoint lastKnownPosition;
@property CGSize glSize;
@property CGFloat glScale;

- (id) initWithSize:(CGSize)size andScale:(CGFloat)scale;
- (void) strokeBegin:(CGPoint)point;
- (void) stroke:(CGPoint)point;
- (void) strokeEnd:(CGPoint)point;

@end
