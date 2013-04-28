#import <Foundation/Foundation.h>

@interface EJAppViewController : UIViewController {
	BOOL landscapeMode;
}

- (void)callJS:(NSString *)statement;

@end
