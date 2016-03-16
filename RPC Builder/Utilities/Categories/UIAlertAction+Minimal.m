//
//  UIAlertAction+Minimal.m
//  RPC Builder
//

#import "UIAlertAction+Minimal.h"

@implementation UIAlertAction (Minimal)

+ (instancetype)simpleOkAction {
    return [self defaultActionWithTitle:@"Ok"
                                handler:nil];
}

+ (instancetype)simpleCancelAction {
    return [UIAlertAction actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleCancel
                                  handler:nil];
}


+ (instancetype)defaultActionWithTitle:(NSString*)title handler:(void (^)(UIAlertAction* action))handler {
    return [UIAlertAction actionWithTitle:title
                                    style:UIAlertActionStyleDefault
                                  handler:handler];
}

@end
