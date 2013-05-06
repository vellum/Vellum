//
//  EJBindingBridge.m
//  Ejecta
//
//  Created by David Lu on 4/30/13.
//
//

#import "EJBindingBridge.h"

@implementation EJBindingBridge

- (id)initWithContext:(JSContextRef)ctx
               object:(JSObjectRef)obj
                 argc:(size_t)argc
                 argv:(const JSValueRef [])argv
{
    if( self = [super initWithContext:ctx object:obj argc:argc argv:argv] ) {
        
        if( argc > 0 ) {
//NSString *s = JSValueToNSString(ctx, value);
        }
    }
    return self;
}

EJ_BIND_SET( screendata, ctx, value) {
    datastring = JSValueToNSString(ctx, value);
    NSLog(@"screencapture: %@", datastring);
}
EJ_BIND_GET(screendata, ctx){
    return JSValueMakeNull(ctx);
}

EJ_BIND_FUNCTION(screencapture, ctx, argc, argv){
    NSLog(@"screencap called, %@", datastring);
    return JSValueMakeNull(ctx);
}

@end
