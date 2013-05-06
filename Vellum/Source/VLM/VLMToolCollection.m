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
	if( !sharedToolCollection ) {
		sharedToolCollection = [[VLMToolCollection alloc] init];
	}
    return sharedToolCollection;
}

- (id)init {

	if( self = [super init] ) {
    
        self.tools = [[NSMutableArray alloc] init];
        
        NSArray *names = [NSArray arrayWithObjects:@"Mesh", @"Dots", @"Line", @"Ink", @"Eraser", @"Scratch", nil];
        NSArray *enableds = [NSArray arrayWithObjects:
                             [NSNumber numberWithBool:YES],
                             [NSNumber numberWithBool:YES],
                             [NSNumber numberWithBool:YES],
                             [NSNumber numberWithBool:NO],
                             [NSNumber numberWithBool:YES],
                             [NSNumber numberWithBool:NO], nil];
        NSArray *jsvals = [NSArray arrayWithObjects:
                           @"MODE_GRAPHITE",
                           @"MODE_DOTS",
                           @"MODE_GRAPHITE",
                           @"MODE_INK",
                           @"MODE_SCRATCH",
                           @"MODE_SCRATCH",
                           nil];

        NSInteger selectedIndex = 0;
        
        for (int i = 0; i < [names count]; i++){
            VLMToolData *data = [[VLMToolData alloc] init];
            data.name = [names objectAtIndex:i];
            data.javascriptvalue = [jsvals objectAtIndex:i];
            data.enabled = [[enableds objectAtIndex:i] boolValue];
            data.selected = (i == selectedIndex);
            [self.tools addObject:data];
        }
	}
	return self;
}

// note: this should really return an array of vlmtooldata objects
// but rewriting headercontroller seemed messy
- (NSMutableArray *)getEnabledTools{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (VLMToolData *item in self.tools){
        if (item.enabled) {
            NSString *name = item.name;
            [ret addObject:name];
        }
    }
    return ret;
}

// if we know the selected index in the headercontroller
// we can suss out which index is selected in the complete collection
- (NSInteger)getSelectedEnabledIndex{
    NSInteger enabledcount = 0;
    for (int i = 0; i < [self.tools count]; i++){
        VLMToolData *item = [self.tools objectAtIndex:i];
        if (item.enabled) {
            if ( i == self.selectedIndex ){
                return enabledcount;
            }
            enabledcount++;
        }
    }
    return -1;
}

- (VLMToolData *)getSelectedToolFromEnabledIndex:(NSInteger)index{
    NSInteger enabledcount = 0;
    VLMToolData *ret = nil;
    for (int i = 0; i < [self.tools count]; i++){
        VLMToolData *item = [self.tools objectAtIndex:i];
        item.selected = NO;
        if (item.enabled) {
            if ( enabledcount == index ){
                item.selected = YES;
                self.selectedIndex = i;
                ret = item;
            }
            enabledcount++;
        }
    }
    return ret;
}

@end
