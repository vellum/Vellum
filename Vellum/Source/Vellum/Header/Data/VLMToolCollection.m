//
//  VLMToolCollection.m
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import "VLMToolCollection.h"
#import "VLMToolData.h"
#import "VLMColorData.h"

//#define DEBUG_DEFAULTS 1

@implementation VLMToolCollection
@synthesize tools;
//@synthesize colors;

static VLMToolCollection *sharedToolCollection;

+ (VLMToolCollection *)instance {
	if (!sharedToolCollection) {
		sharedToolCollection = [[VLMToolCollection alloc] init];
	}
	return sharedToolCollection;
}

- (id)init {
	if (self = [super init]) {
		self.tools = [[NSMutableArray alloc] init];
        
		NSArray *names = @[
		                  @"Scribble",
		                  @"Graphite",
		                  @"Shade",
		                  @"Line",
		                  @"Ink",
                          @"Smudge",
		                  @"Erase",
		                  @"Scratch",
		                  @"Soft Erase",
		                  @"Hard Erase"];
        
		NSArray *enableds = @[
		                     @YES,
		                     @YES,
		                     @YES,
		                     @YES,
                             @YES,
		                     @YES,
                             @YES,
                             @YES,
		                     @YES,
		                     @YES];
        
		NSArray *jsvals = @[
		                   @"VLM.constants.MODE_SCRIBBLE",
		                   @"VLM.constants.MODE_GRAPHITE",
		                   @"VLM.constants.MODE_SHADE",
		                   @"VLM.constants.MODE_LINE",
		                   @"VLM.constants.MODE_INK",
		                   @"VLM.constants.MODE_SMUDGE",
		                   @"VLM.constants.MODE_ERASE",
		                   @"VLM.constants.MODE_SCRATCH",
		                   @"VLM.constants.MODE_GENTLE_ERASE",
		                   @"VLM.constants.MODE_CIRCLE_ERASE"];
        
		NSArray *isSubtractives = @[
		                           @NO,
		                           @NO,
		                           @NO,
		                           @NO,
		                           @NO,
		                           @YES,
		                           @YES,
		                           @YES,
		                           @YES,
		                           @YES];
        
		// FIXME : there should be some code here that reads from local storage
		// if the values don't exist, write them in and add a version number in case data needs to be migrated to a future version
		NSArray *colorindices = @[
		                         @2,
		                         @1,
		                         @1,
		                         @1,
		                         @1,
		                         @0,
		                         @7,
		                         @7,
		                         @5,
		                         @7];

		
        NSArray *isBezierRequireds = @[
                                       @NO,
                                       @NO,
                                       @NO,
                                       @YES,
                                       @YES,
                                       @NO,
                                       @NO,
                                       @NO,
                                       @NO,
                                       @YES];

        
        NSInteger selectedIndex = 0;
		BOOL shouldSynchronize = NO;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
#ifdef DEBUG_DEFAULTS
		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#endif
        
		for (int i = 0; i < [names count]; i++) {
			VLMToolData *data = [[VLMToolData alloc] init];
			[data setName:[names objectAtIndex:i]];
			[data setJavascriptvalue:[jsvals objectAtIndex:i]];
			[data setEnabled:[[enableds objectAtIndex:i] boolValue]];
			[data setSelected:(i == selectedIndex)];
			[data setIsSubtractive:[[isSubtractives objectAtIndex:i] boolValue]];
            [data setIsBezierRequired:[[isBezierRequireds objectAtIndex:i] boolValue]];
            
			NSInteger sel = [[colorindices objectAtIndex:i] integerValue];
			NSString *key = [NSString stringWithFormat:@"%@_colorindex", [data name]];
			if ([defaults objectForKey:key] == nil) {
				//NSLog(@"writing key %@   %d", key, sel);
				[defaults setObject:[NSNumber numberWithInt:sel] forKey:key];
				shouldSynchronize = YES;
			}
			else {
				//NSLog(@"reading key %@   %d", key, sel);
				sel = [defaults integerForKey:key];
			}
			[data setSelectedColorIndex:sel];
            
			[self.tools addObject:data];
            if (i==5){
                [data setColors:@[
                                  [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithWhite:0.0f alpha:1.0f] Label:@"." Opacity:1.0f Enabled:YES Subtractive:YES],
                                  [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithHue:80.0f/360.0f saturation:0.05f brightness:0.24f alpha:1.0f] Label:@"." Opacity:0.75f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithHue:72.0f/360.0f saturation:0.04f brightness:0.47f alpha:1.0f] Label:@"." Opacity:0.5f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithHue:72.0f/360.0f saturation:0.05f brightness:0.71f alpha:1.0f] Label:@"." Opacity:0.25f Enabled:NO Subtractive:NO],
                                  
                                  [[VLMColorData alloc] initWithName:@"white" Color:[UIColor whiteColor] Label:@"." Opacity:1.0f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  [[VLMColorData alloc] initWithName:@"white" Color:[UIColor colorWithHue:61.0f/360.0f saturation:0.01f brightness:0.98f alpha:1.0f] Label:@"." Opacity:0.75f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  [[VLMColorData alloc] initWithName:@"white" Color:[UIColor colorWithHue:48.0f/360.0f saturation:0.02f brightness:0.97f alpha:1.0f] Label:@"." Opacity:0.5f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  [[VLMColorData alloc] initWithName:@"white" Color:[UIColor colorWithHue:73.0f/360.0f saturation:0.04f brightness:0.96f alpha:1.0f] Label:@"." Opacity:0.25f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  
                                  [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:12.0f/360.0f saturation:0.6f brightness:0.42f alpha:1.0f] Label:@"." Opacity:1.0f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:13.0f/360.0f saturation:0.35f brightness:0.55f alpha:1.0f] Label:@"." Opacity:0.75f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:19.0f/360.0f saturation:0.21f brightness:0.68f alpha:1.0f] Label:@"." Opacity:0.5f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:31.0f/360.0f saturation:0.1f brightness:0.82f alpha:1.0f] Label:@"." Opacity:0.25f Enabled:NO Subtractive:NO],
                                  
                                  [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:13.0f/360.0f saturation:0.78f brightness:0.69f alpha:1.0f] Label:@"." Opacity:1.0f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:13.0f/360.0f saturation:0.52f brightness:0.76f alpha:1.0f] Label:@"." Opacity:0.75f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:15.0f/360.0f saturation:0.35f brightness:0.83f alpha:1.0f] Label:@"." Opacity:0.5f Enabled:NO Subtractive:NO],
                                  [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:22.0f/360.0f saturation:0.18f brightness:0.80f alpha:1.0f] Label:@"." Opacity:0.25f Enabled:NO Subtractive:NO],
                                  
                                  [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"ERASE\n25" Opacity:0.25f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"." Opacity:0.5f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"." Opacity:0.75f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]],
                                  [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"." Opacity:1.0f Enabled:NO Subtractive:NO TextColor:[UIColor blackColor]]
                                  
                              ]];
            } else {
            [data setColors:@[
                              [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithWhite:0.0f alpha:1.0f] Label:@"100" Opacity:1.0f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithHue:80.0f/360.0f saturation:0.05f brightness:0.24f alpha:1.0f] Label:@"75" Opacity:0.75f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithHue:72.0f/360.0f saturation:0.04f brightness:0.47f alpha:1.0f] Label:@"50" Opacity:0.5f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"black" Color:[UIColor colorWithHue:72.0f/360.0f saturation:0.05f brightness:0.71f alpha:1.0f] Label:@"25" Opacity:0.25f Enabled:YES Subtractive:NO],
                              
                              [[VLMColorData alloc] initWithName:@"white" Color:[UIColor whiteColor] Label:@"100" Opacity:1.0f Enabled:YES Subtractive:NO TextColor:[UIColor blackColor]],
                              [[VLMColorData alloc] initWithName:@"white" Color:[UIColor colorWithHue:61.0f/360.0f saturation:0.01f brightness:0.98f alpha:1.0f] Label:@"75" Opacity:0.75f Enabled:YES Subtractive:NO TextColor:[UIColor blackColor]],
                              [[VLMColorData alloc] initWithName:@"white" Color:[UIColor colorWithHue:48.0f/360.0f saturation:0.02f brightness:0.97f alpha:1.0f] Label:@"50" Opacity:0.5f Enabled:YES Subtractive:NO TextColor:[UIColor blackColor]],
                              [[VLMColorData alloc] initWithName:@"white" Color:[UIColor colorWithHue:73.0f/360.0f saturation:0.04f brightness:0.96f alpha:1.0f] Label:@"25" Opacity:0.25f Enabled:YES Subtractive:NO TextColor:[UIColor blackColor]],

                              [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:12.0f/360.0f saturation:0.6f brightness:0.42f alpha:1.0f] Label:@"100" Opacity:1.0f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:13.0f/360.0f saturation:0.35f brightness:0.55f alpha:1.0f] Label:@"75" Opacity:0.75f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:19.0f/360.0f saturation:0.21f brightness:0.68f alpha:1.0f] Label:@"50" Opacity:0.5f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"brown" Color:[UIColor colorWithHue:31.0f/360.0f saturation:0.1f brightness:0.82f alpha:1.0f] Label:@"25" Opacity:0.25f Enabled:YES Subtractive:NO],
                              
                              [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:13.0f/360.0f saturation:0.78f brightness:0.69f alpha:1.0f] Label:@"100" Opacity:1.0f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:13.0f/360.0f saturation:0.52f brightness:0.76f alpha:1.0f] Label:@"75" Opacity:0.75f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:15.0f/360.0f saturation:0.35f brightness:0.83f alpha:1.0f] Label:@"50" Opacity:0.5f Enabled:YES Subtractive:NO],
                              [[VLMColorData alloc] initWithName:@"red" Color:[UIColor colorWithHue:22.0f/360.0f saturation:0.18f brightness:0.80f alpha:1.0f] Label:@"25" Opacity:0.25f Enabled:YES Subtractive:NO],
                              
                              [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"ERASE\n25" Opacity:0.25f Enabled:YES Subtractive:YES TextColor:[UIColor blackColor]],
                              [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"50" Opacity:0.5f Enabled:YES Subtractive:YES TextColor:[UIColor blackColor]],
                              [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"75" Opacity:0.75f Enabled:YES Subtractive:YES TextColor:[UIColor blackColor]],
                              [[VLMColorData alloc] initWithName:@"erase" Color:[UIColor colorWithHue:70.0f/360.0f saturation:0.05f brightness:0.95f alpha:1.0f] Label:@"100" Opacity:1.0f Enabled:YES Subtractive:YES TextColor:[UIColor blackColor]]
              ]];
            }
		}
		if (shouldSynchronize) {
			[defaults synchronize];
		}
	}
	return self;
}

// note: this should really return an array of vlmtooldata objects
// but rewriting headercontroller seemed messy
- (NSMutableArray *)getEnabledTools {
	NSMutableArray *ret = [[NSMutableArray alloc] init];
	for (VLMToolData *item in self.tools) {
		if (item.enabled) {
			NSString *name = item.name;
			[ret addObject:name];
		}
	}
	return ret;
}

// if we know the selected index in the headercontroller
// we can suss out which index is selected in the complete collection
- (NSInteger)getSelectedEnabledIndex {
	NSInteger enabledcount = 0;
	for (int i = 0; i < [self.tools count]; i++) {
		VLMToolData *item = [self.tools objectAtIndex:i];
		if (item.enabled) {
			if (i == self.selectedIndex) {
				return enabledcount;
			}
			enabledcount++;
		}
	}
	return -1;
}

- (VLMToolData *)getSelectedToolFromEnabledIndex:(NSInteger)index {
	NSInteger enabledcount = 0;
	VLMToolData *ret = nil;
	for (int i = 0; i < [self.tools count]; i++) {
		VLMToolData *item = [self.tools objectAtIndex:i];
		[item setSelected:NO];
		if (item.enabled) {
			if (enabledcount == index) {
				[item setSelected:YES];
				[self setSelectedIndex:i];
				ret = item;
			}
			enabledcount++;
		}
	}
	return ret;
}

- (BOOL)isSelectedToolSubtractive {
	VLMToolData *tool = (VLMToolData *)[self.tools objectAtIndex:self.selectedIndex];
	return tool.isSubtractive;
}

- (BOOL)isToggleable {
	if ([[self getEnabledTools] count] == 0) return NO;
	return YES;
}

@end
