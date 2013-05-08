//
//  VLMTapGestureRecognizer.m
//  Ejecta
//
//  Created by David Lu on 5/4/13.
//
//

#import "VLMTapGestureRecognizer.h"

@implementation VLMTapGestureRecognizer
@synthesize numberOfTouches;
@synthesize travel;
@synthesize travelthreshold;

- (id)init {
    if (self = [super init]) {
        self.numberOfTouches = 0;
        self.previous = CGPointZero;
        self.travelthreshold = 4;
        self.travel = 0;
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        self.numberOfTouches = 0;
        self.previous = CGPointZero;
        self.travelthreshold = 4;
        self.travel = 0;
    }
    return self;
}

// note: should override reset but i'm lazy

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    [super touchesBegan:touches withEvent:event];
    
    CGPoint p = [[touches anyObject] locationInView: self.view];
    //NSLog(@"%@", p);
    self.previous = p;
    self.travel = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    
    [super touchesMoved:touches withEvent:event];

    CGPoint p = [[touches anyObject] locationInView: self.view];
    CGFloat dx = p.x - self.previous.x;
    CGFloat dy = p.y - self.previous.y;
    CGFloat d = sqrtf(dx*dx + dy*dy);
    self.previous = p;
    self.travel += d;
    if (self.travel > self.travelthreshold){
        self.state = UIGestureRecognizerStateFailed;
    }
    NSLog(@"travel %f", self.travel);

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    self.numberOfTouches = touchcount - [touches count];
    [super touchesCancelled:touches withEvent:event];
}
@end
