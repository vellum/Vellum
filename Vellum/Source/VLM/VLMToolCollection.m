//
//  VLMToolCollection.m
//  Ejecta
//
//  Created by David Lu on 5/6/13.
//
//

#import "VLMToolCollection.h"
#import "VLMToolData.h"

@implementation VLMToolCollection
@synthesize tools;

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
        
        NSArray *names = [NSArray arrayWithObjects:
                          @"Scribble",    //1
                          @"Graphite",    //0
                          @"Shade",       //2
                          @"Line",        //3
                          @"Ink ",        //4
                          @"Erase",       //5
                          @"Scratch",     //6
                          nil];
        NSArray *enableds = [NSArray arrayWithObjects:
                             [NSNumber numberWithBool:YES], //1
                             [NSNumber numberWithBool:YES], //0
                             [NSNumber numberWithBool:YES], //2
                             [NSNumber numberWithBool:YES], //3
                             [NSNumber numberWithBool:YES], //4
                             [NSNumber numberWithBool:YES], //5
                             [NSNumber numberWithBool:YES], //6
                             nil];
        NSArray *jsvals = [NSArray arrayWithObjects:
                           @"MODE_SCRIBBLE",    //1
                           @"MODE_GRAPHITE",    //0
                           @"MODE_SHADE",       //2
                           @"MODE_OUTLINE",     //3
                           @"MODE_INK",         //4
                           @"MODE_ERASE",       //5
                           @"MODE_SCRATCH",     //6
                           nil];
        NSArray *isSubtractives = [NSArray arrayWithObjects:
                                   [NSNumber numberWithBool:NO], //1
                                   [NSNumber numberWithBool:NO], //0
                                   [NSNumber numberWithBool:NO], //2
                                   [NSNumber numberWithBool:NO], //3
                                   [NSNumber numberWithBool:NO], //4
                                   [NSNumber numberWithBool:YES], //5
                                   [NSNumber numberWithBool:YES], //6
                                   nil];
        
        NSInteger selectedIndex = 0;
        
        for (int i = 0; i < [names count]; i++) {
            VLMToolData *data = [[VLMToolData alloc] init];
            [data setName:[names objectAtIndex:i]];
            [data setJavascriptvalue:[jsvals objectAtIndex:i]];
            [data setEnabled:[[enableds objectAtIndex:i] boolValue]];
            [data setSelected:(i == selectedIndex)];
            [data setIsSubtractive:[[isSubtractives objectAtIndex:i] boolValue]];
            [self.tools addObject:data];
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

- (BOOL)isToggleable{
    if ( [[self getEnabledTools] count] == 0 ) return NO;
    return YES;
}
@end
