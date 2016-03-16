//
//  UIAlertController+Minimal.m
//  RPC Builder
//

#import "UIAlertController+Minimal.h"

@implementation UIAlertController (Minimal)

+ (instancetype)simpleAlertWithTitle:(NSString*)title message:(NSString*)message {
    return [self alertWithTitle:title message:message action:[UIAlertAction simpleOkAction]];
}

+ (instancetype)alertWithTitle:(NSString*)title message:(NSString*)message action:(UIAlertAction*)action {
    UIAlertController* alertController = [self alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    if (action) {
        [alertController addAction:action];
    }
    return alertController;
}

+ (instancetype)actionSheetWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController* alertController = [self alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    return alertController;
}

- (void)addDefaultActionWithTitle:(NSString *)title handler:(void (^)(UIAlertAction *))handler {
    [self sdl_addActionWithTitle:title
                           style:UIAlertActionStyleDefault
                         handler:handler];
}

- (void)addDestructiveActionWithTitle:(NSString *)title handler:(void (^)(UIAlertAction *))handler {
    [self sdl_addActionWithTitle:title
                           style:UIAlertActionStyleDestructive
                         handler:handler];
}

- (void)addCancelAction {
    [self addAction:[UIAlertAction simpleCancelAction]];
}

#pragma mark - Private
- (void)sdl_addActionWithTitle:(NSString*)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler {
    [self addAction:[UIAlertAction actionWithTitle:title
                                             style:style
                                           handler:handler]];
}

@end
