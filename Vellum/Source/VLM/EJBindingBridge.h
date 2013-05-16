//
//  EJBindingBridge.h
//  Ejecta
//
//  Created by David Lu on 4/30/13.
//
//

#import "EJBindingBase.h"

@interface EJBindingBridge : EJBindingBase{
    NSInteger undoCount;
    NSInteger undoIndex;
    BOOL isPad;
    BOOL isRetina;
}
@end
