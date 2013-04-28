//
//  VLMTouchableView.m
//  Vellum
//
//  Created by David Lu on 4/4/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMTouchableView.h"

@interface VLMTouchableView()
//- (BOOL)shouldBeEnabled;
@end

@implementation VLMTouchableView



@synthesize delegate;
@synthesize enabled;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// start a new line
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];

    NSLog(@"touchesbegan %i", touchcount);
    if ( touchcount > 1 ) {
        self.enabled = NO;
    } else {
        self.enabled = YES;
    }
    
    if ( self.delegate == nil || touchcount != 1 || !self.enabled ) return;
    UITouch *touch = [touches anyObject];
    [self.delegate singleFingerPanBegan:touch];
}

// continue line
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];
    if ( touchcount != 1 ) self.enabled = NO;
    
    NSLog(@"touchesmoved %i", touchcount);
    if ( self.delegate == nil || touchcount != 1 || !self.enabled ) return;
    UITouch *touch = [touches anyObject];
    [self.delegate singleFingerPanChanged:touch];
}

// end the line
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSArray *touchesfromevent = [[event allTouches] allObjects];
	int touchcount = [touchesfromevent count];

    NSLog(@"touchesended %i", touchcount);
    if ( touchcount <= 1 ){
        self.enabled = YES;
        if ( self.delegate != nil )
            [self.delegate singleFingerPanEnded:nil];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
