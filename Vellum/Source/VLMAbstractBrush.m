//
//  VLMAbstractBrush.m
//  Vellum
//
//  Created by David Lu on 4/3/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMAbstractBrush.h"

@implementation VLMAbstractBrush

@synthesize lastKnownPosition;
@synthesize glSize;

- (id) initWithSize:(CGSize)size andScale:(CGFloat)scale{
    self = [super init];
    lastKnownPosition = CGPointZero;
    self.glSize = size;
    self.glScale = scale;
    return self;
}

- (void) strokeBegin:(CGPoint)point{
    self.lastKnownPosition = point;
    NSLog(@"start");
}

- (void) stroke:(CGPoint)point{
    NSLog(@"stroke: %f, %f to %f, %f", lastKnownPosition.x, lastKnownPosition.y, point.x, point.y);

    static GLfloat*		vertexBuffer = NULL;
	static NSUInteger	vertexMax = 64;
	NSUInteger			vertexCount = 0;
	
	if(vertexBuffer == NULL)
		vertexBuffer = malloc(vertexMax * 2 * sizeof(GLfloat));

    vertexBuffer[vertexCount] = lastKnownPosition.x;
    vertexBuffer[++vertexCount] = lastKnownPosition.y;
    vertexBuffer[++vertexCount] = point.x;
    vertexBuffer[++vertexCount] = point.y;
    
    self.lastKnownPosition = point;
    
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
	effect.useConstantColor = YES;
    effect.constantColor = GLKVector4Make(0, 0, 0, 1);

	effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, self.glSize.width, self.glSize.height, 0, -2, 2);
	CGFloat scale = self.glScale;	// need scale to handle Retina displays

    glLineWidth(2.0f * scale);

    // Render the vertex array
    [effect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    NSUInteger firstInd = 0;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, &vertexBuffer[firstInd*2]);
    glDrawArrays(GL_LINE_STRIP, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribPosition);

    
}

- (void) strokeEnd:(CGPoint)point{
    self.lastKnownPosition = point;
    
    NSLog(@"end");
}

@end
