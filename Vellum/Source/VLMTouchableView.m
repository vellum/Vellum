//
//  VLMTouchableView.m
//  Vellum
//
//  Created by David Lu on 4/4/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMTouchableView.h"

@implementation VLMTouchableView
@synthesize delegate;

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
    NSLog(@"touchesbegan");
    if ( self.delegate == nil || [touches count] != 1 ) return;
    UITouch *touch = [touches anyObject];
    [self.delegate singleFingerPanBegan:touch];
}

// continue line
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesmoved");
    if ( self.delegate == nil || [touches count] != 1 ) return;
    UITouch *touch = [touches anyObject];
    [self.delegate singleFingerPanChanged:touch];
}

// end the line
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesended");
    if ( self.delegate == nil || [touches count] != 1 ) return;
    UITouch *touch = [touches anyObject];
    [self.delegate singleFingerPanEnded:touch];
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
