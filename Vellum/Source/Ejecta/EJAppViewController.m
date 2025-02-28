#import <objc/runtime.h>

#import "EJAppViewController.h"
#import "EJJavaScriptView.h"
#import "VLMConstants.h"

@implementation EJAppViewController
@synthesize shouldDoubleResolution;

- (id)init{
	if( self = [super init] ) {
		landscapeMode = [[[NSBundle mainBundle] infoDictionary][@"UIInterfaceOrientation"]
			hasPrefix:@"UIInterfaceOrientationLandscape"];
        shouldDoubleResolution = NO;
	}
	return self;
}

- (void)dealloc {
	self.view = nil;
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	[(EJJavaScriptView *)self.view clearCaches];
}

- (void)loadView {
	CGRect frame = UIScreen.mainScreen.bounds;
	
    /*
    if( landscapeMode ) {
		frame.size = CGSizeMake(frame.size.height, frame.size.width);
	}
    */
    
    
    // from http://stackoverflow.com/questions/3504173/detect-retina-display
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        // do nothing, the underlying canvas object will double the pixels
    } else {
        // non-Retina display
        // if this is a low-res non-retina display (eg iPhone 3GS), double the size of the view
        shouldDoubleResolution = YES;
        frame.size.width *= OLD_DEVICE_SCREEN_MULTIPLIER;
        frame.size.height *= OLD_DEVICE_SCREEN_MULTIPLIER;
    }
	EJJavaScriptView *view = [[EJJavaScriptView alloc] initWithFrame:frame];
	self.view = view;
	[view loadScriptAtPath:@"tinycolor.js"];	
	[view loadScriptAtPath:@"vellum.js"];
	[view loadScriptAtPath:@"brushes/scribble.js"];
	[view loadScriptAtPath:@"brushes/graphite.js"];
	[view loadScriptAtPath:@"brushes/shade.js"];
	[view loadScriptAtPath:@"brushes/line.js"];
	[view loadScriptAtPath:@"brushes/ink.js"];
	[view loadScriptAtPath:@"brushes/smudge.js"];
	[view loadScriptAtPath:@"brushes/erase.js"];
	[view loadScriptAtPath:@"brushes/scratch.js"];
	[view loadScriptAtPath:@"brushes/softerase.js"];
	[view loadScriptAtPath:@"brushes/harderase.js"];
	[view loadScriptAtPath:@"index.js"];
	[view release];
}

- (NSUInteger)supportedInterfaceOrientations {
    /*
	if( landscapeMode ) {
		// Allow Landscape Left and Right
		return UIInterfaceOrientationMaskLandscape;
	}
	else {
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            return UIInterfaceOrientationMaskLandscape;
			// Allow Portrait UpsideDown on iPad
			//return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
		}
		else {
			// Only Allow Portrait
			return UIInterfaceOrientationMaskPortrait;
		}
	}*/
    return UIInterfaceOrientationMaskPortrait;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	// Deprecated in iOS6 - supportedInterfaceOrientations is the new way to do this
	// We just use the mask returned by supportedInterfaceOrientations here to check if
	// this particular orientation is allowed.
	//return ( self.supportedInterfaceOrientations & (1 << orientation) );
    return NO;
}

#pragma mark - additions from DL

- (void)callJS:(NSString *)statement{
	EJJavaScriptView *view = (EJJavaScriptView *)self.view;
    [view loadScript:statement sourceURL:@""];
    
}


@end
