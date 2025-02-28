//
//  VLMTapGestureRecognizer.m
//  Ejecta
//
//  Created by David Lu on 5/4/13.
//
//

#import "VLMTapGestureRecognizer.h"
#define VLM_TAP_MAX_TRAVEL_DISTANCE 7.0f
@implementation VLMTapGestureRecognizer
@synthesize numberOfTouches;
@synthesize travel;
@synthesize travelthreshold;

- (id)init {
	if (self = [super init]) {
		[self setNumberOfTouches:0];
		[self setPrevious:CGPointZero];
		[self setTravelthreshold:VLM_TAP_MAX_TRAVEL_DISTANCE];
		[self setTravel:0];
	}
	return self;
}

- (id)initWithTarget:(id)target action:(SEL)action {
	if (self = [super initWithTarget:target action:action]) {
		[self setNumberOfTouches:0];
		[self setPrevious:CGPointZero];
		[self setTravelthreshold:VLM_TAP_MAX_TRAVEL_DISTANCE];
		[self setTravel:0];
	}
	return self;
}

// note: should override reset but i'm lazy

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
	[self setNumberOfTouches:touchcount];
	[super touchesBegan:touches withEvent:event];
    
	CGPoint p = [[touches anyObject] locationInView:self.view];
	[self setPrevious:p];
	[self setTravel:0];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
	[self setNumberOfTouches:touchcount];
	[super touchesMoved:touches withEvent:event];
    
	CGPoint p = [[touches anyObject] locationInView:self.view];
	CGFloat dx = p.x - self.previous.x;
	CGFloat dy = p.y - self.previous.y;
	CGFloat d = sqrtf(dx * dx + dy * dy);
	[self setPrevious:p];
	[self setTravel:self.travel + d];
	if (self.travel > self.travelthreshold) {
		[self setState:UIGestureRecognizerStateFailed];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
	[self setNumberOfTouches:touchcount];
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
	[self setNumberOfTouches:touchcount - [touches count]];
	[super touchesCancelled:touches withEvent:event];
}

@end
