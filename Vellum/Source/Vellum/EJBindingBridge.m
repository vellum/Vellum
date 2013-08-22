//
//  EJBindingBridge.m
//  Ejecta
//
//  Created by David Lu on 4/30/13.
//
//

#import "EJBindingBridge.h"
#import "VLMMainViewController.h"
#import "AppDelegate.h"

@implementation EJBindingBridge

- (id)initWithContext:(JSContextRef)ctx
               object:(JSObjectRef)obj
                 argc:(size_t)argc
                 argv:(const JSValueRef[])argv {
	if (self = [super initWithContext:ctx object:obj argc:argc argv:argv]) {
		if (argc > 0) {
		}
	}
	return self;
}

// undocount
EJ_BIND_SET(undoCount, ctx, value)
{
	undoCount = JSValueToNumberFast(ctx, value);
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	VLMMainViewController *mvc = [delegate mainViewController];
	[mvc updateUndoCount:undoCount];
}

EJ_BIND_GET(undoCount, ctx)
{
	return JSValueMakeNull(ctx);
}

// undoindex
EJ_BIND_SET(undoIndex, ctx, value)
{
	undoIndex = JSValueToNumberFast(ctx, value);
	AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	VLMMainViewController *mvc = [delegate mainViewController];
	[mvc updateUndoIndex:undoIndex];
}

EJ_BIND_GET(undoIndex, ctx)
{
	return JSValueMakeNull(ctx);
}

// isIPad
EJ_BIND_SET(isIPad, ctx, value)
{
	// do nothing. not settable.
}

EJ_BIND_GET(isIPad, ctx)
{
	return JSValueMakeBoolean(ctx, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad));
}

// isUndoCapable
EJ_BIND_SET(isUndoCapable, ctx, value)
{
	// do nothing. not settable.
}

EJ_BIND_GET(isUndoCapable, ctx)
{
    BOOL retVal = [AppDelegate isUndoCapable];
	return JSValueMakeBoolean(ctx, retVal);
}


@end
