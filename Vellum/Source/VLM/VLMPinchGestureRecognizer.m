//
//  VLMPinchGestureRecognizer.m
//  Ejecta
//
//  Created by David Lu on 5/4/13.
//
//

#import "VLMPinchGestureRecognizer.h"

@implementation VLMPinchGestureRecognizer

- (id)init {
    if (self = [super init]) {
        self.numberOfTouches = 0;
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        self.numberOfTouches = 0;
    }
    return self;
}

// note: should override reset but i'm lazy

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    
    if ( touchcount > 2 ) {
        self.state = UIGestureRecognizerStateFailed;
        [self reset];
        return;
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    if ( touchcount > 2 ) {
        self.state = UIGestureRecognizerStateFailed;
        [self reset];
        return;
    }
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    if ( touchcount > 2 ) {
        self.state = UIGestureRecognizerStateFailed;
        [self reset];
        return;
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount - [touches count];
    if ( touchcount > 2 ) {
        self.state = UIGestureRecognizerStateFailed;
        [self reset];
        return;
    }
    [super touchesCancelled:touches withEvent:event];
}

@end
