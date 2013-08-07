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
		                     @YES];
        
		NSArray *jsvals = @[
		                   @"VLM.constants.MODE_SCRIBBLE",
		                   @"VLM.constants.MODE_GRAPHITE",
		                   @"VLM.constants.MODE_SHADE",
		                   @"VLM.constants.MODE_LINE",
		                   @"VLM.constants.MODE_INK",
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
		                           @YES];
        
		// FIXME : there should be some code here that reads from local storage
		// if the values don't exist, write them in and add a version number in case data needs to be migrated to a future version
		NSArray *colorindices = @[
		                         @2,
		                         @1,
		                         @1,
		                         @1,
		                         @1,
		                         @7,
		                         @7,
		                         @5,
		                         @7];
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
			if (i == 4) {
				[data setColors:@[
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"BLACK\n100" Opacity:1.0f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"80" Opacity:0.8f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"60" Opacity:0.6f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"40" Opacity:0.4f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"20" Opacity:0.2f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"10" Opacity:0.1f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"WHITE\n0" Opacity:0.0f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"erase" Label:@"ERASE\n100" Opacity:1.0f Enabled:YES Subtractive:YES]]];
			}
			else if (i == 8) {
				[data setColors:@[
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"BLACK\n100" Opacity:1.0f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"/" Label:@"·" Opacity:0.0f Enabled:NO Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"/" Label:@"·" Opacity:0.0f Enabled:NO Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"/" Label:@"·" Opacity:0.0f Enabled:NO Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"/" Label:@"ERASE\n·" Opacity:0.0f Enabled:NO Subtractive:YES],
				                 [[VLMColorData alloc] initWithName:@"/" Label:@"·" Opacity:0.0f Enabled:NO Subtractive:YES],
				                 [[VLMColorData alloc] initWithName:@"/" Label:@"·" Opacity:0.0f Enabled:NO Subtractive:YES],
				                 [[VLMColorData alloc] initWithName:@"erase" Label:@"100" Opacity:1.0f Enabled:YES Subtractive:YES]]];
			}
			else {
				[data setColors:@[
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"BLACK\n100" Opacity:1.0f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"75" Opacity:0.75f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"50" Opacity:0.5f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"black" Label:@"25" Opacity:0.25f Enabled:YES Subtractive:NO],
				                 [[VLMColorData alloc] initWithName:@"erase" Label:@"ERASE\n25" Opacity:0.25f Enabled:YES Subtractive:YES],
				                 [[VLMColorData alloc] initWithName:@"erase" Label:@"50" Opacity:0.5f Enabled:YES Subtractive:YES],
				                 [[VLMColorData alloc] initWithName:@"erase" Label:@"75" Opacity:0.75f Enabled:YES Subtractive:YES],
				                 [[VLMColorData alloc] initWithName:@"erase" Label:@"100" Opacity:1.0f Enabled:YES Subtractive:YES]]];
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
