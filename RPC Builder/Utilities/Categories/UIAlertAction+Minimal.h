//
//  UIAlertAction+Minimal.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

@interface UIAlertAction (Minimal)

+ (instancetype)simpleOkAction;

+ (instancetype)simpleCancelAction;

+ (instancetype)defaultActionWithTitle:(NSString*)title handler:(void (^)(UIAlertAction* action))handler;

@end
