//
//  VLMSinglePanGestureRecognizer.h
//  Vellum
//
//  Created by David Lu on 4/25/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface VLMSinglePanGestureRecognizer : UIGestureRecognizer

@property (nonatomic) CGPoint anchorPoint;
@property (nonatomic) CGPoint dragPoint;

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
