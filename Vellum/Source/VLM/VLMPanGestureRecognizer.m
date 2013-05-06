//
//  VLMPanGestureRecognizer.m
//  Ejecta
//
//  Created by David Lu on 5/3/13.
//
//

#import "VLMPanGestureRecognizer.h"

@implementation VLMPanGestureRecognizer
@synthesize shouldFailWhenNumberOfTouchesExceedsRange;
@synthesize shouldFailWhenNumberOfTouchesBelowRange;
@synthesize numberOfTouches;

- (id)init {
    if (self = [super init]) {
        self.shouldFailWhenNumberOfTouchesExceedsRange = YES;
        self.shouldFailWhenNumberOfTouchesBelowRange = NO;
        self.numberOfTouches = 0;
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        self.shouldFailWhenNumberOfTouchesExceedsRange = YES;
        self.shouldFailWhenNumberOfTouchesBelowRange = NO;
        self.numberOfTouches = 0;
    }
    return self;
}

// note: should override reset but i'm lazy

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;

    [super touchesBegan:touches withEvent:event];
    if ( self.shouldFailWhenNumberOfTouchesBelowRange && touchcount < self.minimumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    if ( self.shouldFailWhenNumberOfTouchesExceedsRange && touchcount > self.maximumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    
    [super touchesMoved:touches withEvent:event];
    if ( self.shouldFailWhenNumberOfTouchesBelowRange && touchcount < self.minimumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    if ( self.shouldFailWhenNumberOfTouchesExceedsRange && touchcount > self.maximumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;

    [super touchesEnded:touches withEvent:event];

    if ( self.shouldFailWhenNumberOfTouchesBelowRange && touchcount < self.minimumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    if ( self.shouldFailWhenNumberOfTouchesExceedsRange && touchcount > self.maximumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount - [touches count];

    if ( self.shouldFailWhenNumberOfTouchesBelowRange && touchcount < self.minimumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    if ( self.shouldFailWhenNumberOfTouchesExceedsRange && touchcount > self.maximumNumberOfTouches ){
        self.state = UIGestureRecognizerStateFailed;
    }
    [super touchesCancelled:touches withEvent:event];
}

@end
