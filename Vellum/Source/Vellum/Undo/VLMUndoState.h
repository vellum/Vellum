//
//  VLMUndoState.h
//  Vellum
//
//  Created by David Lu on 5/9/13.
//
//

#import <Foundation/Foundation.h>

@interface VLMUndoState : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic, strong) UIImage *image;

- (id)initWithImage:(UIImage *)existingImage;

@end
