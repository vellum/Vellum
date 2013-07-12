//
//  VLMActivityProvider.m
//  Vellum
//
//  Created by David Lu on 7/11/13.
//
//

#import "VLMActivityProvider.h"

@implementation VLMActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        return @"#madeWithVellum cc/ @vellumapp ";
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
        return @"Made with Vellum (http://vellumapp.com) ";
    if ( [activityType isEqualToString:UIActivityTypeMessage] )
        return @"Made with Vellum (http://vellumapp.com) ";
    if ( [activityType isEqualToString:UIActivityTypeMail] )
        return @"Made with Vellum (http://vellumapp.com) ";
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

@end
