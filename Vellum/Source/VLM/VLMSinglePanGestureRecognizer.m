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
    self.anchorPoint = CGPointZero;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    [super touchesBegan:touches withEvent:event];
    
    if (touchcount != 1 /* || [[touches anyObject] tapCount] > 1*/) {
        NSLog(@"single pan failing with more than one touch");
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStateBegan;
    self.anchorPoint = [[touches anyObject] locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    
    [super touchesMoved:touches withEvent:event];
    if (touchcount != 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    if (self.state == UIGestureRecognizerStateFailed) return;
    self.dragPoint = [[touches anyObject] locationInView:self.view];
    self.state = UIGestureRecognizerStateChanged;
    
    return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateFailed;
}

@end
