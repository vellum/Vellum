//
//  VLMOpaButton.m
//  Vellum
//
//  Created by David Lu on 7/25/13.
//
//

#import "VLMOpaButton.h"
#import "VLMConstants.h"
#import "VLMCustomXView.h"
#import "VLMCustomBarView.h"

#define h 26.0f

@interface VLMOpaButton ()
@property (nonatomic, strong) UIView *shade;
@property (nonatomic, strong) UIView *contentview;
@property CGRect contentrect;
@end

@implementation VLMOpaButton
@synthesize shade;
@synthesize contentview;
@synthesize contentrect;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-h, frame.size.width, h)];
        [mask setClipsToBounds:YES];
        [mask setUserInteractionEnabled:NO];
        [mask setBackgroundColor:[UIColor clearColor]];
        [self addSubview:mask];
        
        UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, h*2)];
        [content setUserInteractionEnabled:NO];
        [content setBackgroundColor:[UIColor clearColor]];
        [mask addSubview:content];
        [self setContentrect:content.frame];
        [self setContentview:content];
        
        VLMCustomBarView *a = [[VLMCustomBarView alloc] initWithFrame:CGRectMake(0, h, frame.size.width, h)];
        [content addSubview:a];
        
        VLMCustomXView *b = [[VLMCustomXView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, h)];
        [content addSubview:b];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setShade:[[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
        [self.shade setUserInteractionEnabled:NO];
        [self.shade setBackgroundColor:[UIColor blackColor]];
        [self.shade setAlpha:0.0f];
        [self addSubview:self.shade];
        [self hide];
        
        [self addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)hide{
    [self setUserInteractionEnabled:NO];
    //[self.contentview setFrame:CGRectOffset(self.contentrect, 0, -h*2)];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    [self.contentview setFrame:CGRectOffset(self.contentrect, 0, -h*2)];
    [self setAlpha:0.0f];
    [UIView commitAnimations];
    
}

- (void)show{
    [self setUserInteractionEnabled:YES];
    //[self.contentview setFrame:CGRectOffset(self.contentrect, 0, -h)];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:0.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:ANIMATION_DURATION*2];
    [self.contentview setFrame:CGRectOffset(self.contentrect, 0, -h)];
    [self setAlpha:1.0f];
    [UIView commitAnimations];
}


// from http://stackoverflow.com/questions/15237956/how-to-animate-transition-from-one-state-to-another-for-uicontrol-uibutton
-(void)setHighlighted:(BOOL)highlighted
{
    // Check if button is going from not highlighted to highlighted
    if(![self isHighlighted] && highlighted) {
        [self.shade setAlpha:0.5f];
    }
    // Check if button is going from highlighted to not highlighted
    else if([self isHighlighted] && !highlighted) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [self.shade setAlpha:0.0f];
        [UIView commitAnimations];
    }
    [super setHighlighted:highlighted];
}


- (BOOL)isSubMenuOpen{
    if ( self.contentview.frame.origin.y == 0 ) return YES;
    return NO;
}

- (void)handleTap{
    if ([self isSubMenuOpen]){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION * 2 ];
        [self.contentview setFrame:CGRectOffset(self.contentrect, 0, -h)];
        [self setAlpha:1.0f];
        [UIView commitAnimations];

    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelay:0.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:ANIMATION_DURATION *2];
        [self.contentview setFrame:CGRectOffset(self.contentrect, 0, 0)];
        [self setAlpha:1.0f];
        [UIView commitAnimations];
    }
}
@end
