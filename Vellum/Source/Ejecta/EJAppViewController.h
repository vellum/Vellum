#import <Foundation/Foundation.h>

@interface EJAppViewController : UIViewController {
	BOOL landscapeMode;
    BOOL shouldDoubleResolution;
}

@property (nonatomic) BOOL shouldDoubleResolution;

- (void)callJS:(NSString *)statement;

@end
