//
//  UIAlertController+Minimal.h
//  RPC Builder
//

#import <UIKit/UIKit.h>
#import "UIAlertAction+Minimal.h"

@interface UIAlertController (Minimal)

+ (instancetype)simpleAlertWithTitle:(NSString*)title message:(NSString*)message;

+ (instancetype)simpleErrorAlertWithMessage:(NSString*)message;

+ (instancetype)alertWithTitle:(NSString*)title message:(NSString*)message action:(UIAlertAction*)action;

+ (instancetype)actionSheetWithTitle:(NSString*)title message:(NSString*)message;

- (void)addDefaultActionWithTitle:(NSString*)title handler:(void (^)(UIAlertAction* action))handler;
- (void)addDestructiveActionWithTitle:(NSString*)title handler:(void (^)(UIAlertAction* action))handler;
- (void)addCancelAction;

@end
