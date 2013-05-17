//
//  VLMActivitySaveToAlbum.m
//  Vellum
//
//  Created by David Lu on 5/16/13.
//
//

#import "VLMActivitySaveToAlbum.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@implementation VLMActivitySaveToAlbum

- (NSString *)activityType {
    return @"UIActivityTypeSaveToVellumAlbum";
}

- (NSString *)activityTitle {
    return @"Save to \nPhoto Album";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"camera.png"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    
    return YES;

}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) self.shareImage = item;
        else if ([item isKindOfClass:[NSString class]]) {
            self.shareString = item;
        }
        else NSLog(@"Unknown item type %@", item);
    }
}

- (void)performActivity {
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library saveImage:self.shareImage toAlbum:@"Vellum" withCompletionBlock:nil];
    [self activityDidFinish:YES];
}


@end
