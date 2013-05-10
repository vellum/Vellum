//
//  VLMSinglePanGestureRecognizer.m
//  Vellum
//
//  Created by David Lu on 4/25/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMSinglePanGestureRecognizer.h"

@implementation VLMSinglePanGestureRecognizer

@synthesize anchorPoint = _anchorPoint;
@synthesize dragPoint = _dragPoint;

#pragma mark -
#pragma mark Initialization


- (id)init {
    if (self = [super init]) {
        // custom code here
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        // custom code here
    }
    return self;
}

#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"VLMSinglePanGestureRecognizer anchorPoint=(%f, %f) dragPoint(%f, %f)", self.anchorPoint.x, self.anchorPoint.y, self.dragPoint.x, self.dragPoint.y];
}

#pragma mark -
#pragma mark UIGestureRecognizer implementation

- (void)reset {
    [super reset];
    [self setAnchorPoint:CGPointZero];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    [super touchesBegan:touches withEvent:event];
    
    if (touchcount != 1) {
        [self setState:UIGestureRecognizerStateFailed];
        return;
    }
    [self setState:UIGestureRecognizerStateBegan];
    [self setAnchorPoint:[[touches anyObject] locationInView:self.view]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    
    [super touchesMoved:touches withEvent:event];
    if (touchcount != 1) {
        [self setState:UIGestureRecognizerStateFailed];
        return;
    }
    if (self.state == UIGestureRecognizerStateFailed) return;
    
    [self setDragPoint:[[touches anyObject] locationInView:self.view]];
    
    [self setState:UIGestureRecognizerStateChanged];
    
    return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setState:UIGestureRecognizerStateEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self setState:UIGestureRecognizerStateFailed];
}

@end
