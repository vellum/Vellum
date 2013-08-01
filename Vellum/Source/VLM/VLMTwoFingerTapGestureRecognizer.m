//
//  VLMTwoFingerTapGestureRecognizer.m
//  Vellum
//
//  Created by David Lu on 7/5/13.
//
//

#import "VLMTwoFingerTapGestureRecognizer.h"
#define VLM_TAP_MAX_TRAVEL_DISTANCE 12.0f

@implementation VLMTwoFingerTapGestureRecognizer
@synthesize numberOfTouches;
@synthesize previous1;
@synthesize previous2;
@synthesize travel1;
@synthesize travel2;
@synthesize travelthreshold;

- (id)init {
    if (self = [super init]) {
        [self setNumberOfTouches:0];
        [self setPrevious1:CGPointZero];
        [self setPrevious2:CGPointZero];
        [self setTravelthreshold:VLM_TAP_MAX_TRAVEL_DISTANCE];
        [self setTravel1:0];
        [self setTravel2:0];
        [self setNumberOfTouchesRequired:2];
        [self setNumberOfTapsRequired:1];
    }
    return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithTarget:target action:action]) {
        [self setNumberOfTouches:0];
        [self setPrevious1:CGPointZero];
        [self setPrevious2:CGPointZero];
        [self setTravelthreshold:VLM_TAP_MAX_TRAVEL_DISTANCE];
        [self setTravel1:0];
        [self setTravel2:0];
        [self setNumberOfTouchesRequired:2];
        [self setNumberOfTapsRequired:1];

    }
    return self;
}

// note: should override reset but i'm lazy

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
    int touchcount = [touchesfromevent count];
    [self setNumberOfTouches:touchcount];
    [super touchesBegan:touches withEvent:event];
    
    //NSLog(@"began %i", touchcount);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    return;
    // ignore pans this is bad
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSArray *touchesfromevent = [touches allObjects];
    int touchcount = [touchesfromevent count];
    //NSLog(@"ended %i", touchcount);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

@end
