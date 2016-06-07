//
//  UIColor+Util.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 6/7/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor (Util)

#pragma mark - RBLogInfo's Type
+ (UIColor*)notificationColor {
    static UIColor* notificationColor = nil;
    if (!notificationColor) {
        notificationColor = [UIColor colorWithRed:241/255.0
                                            green:196/255.0
                                             blue:15/255.0
                                            alpha:0.5];
    }
    return notificationColor;
}

+ (UIColor*)responseColor {
    static UIColor* responseColor = nil;
    if (!responseColor) {
        responseColor = [UIColor colorWithRed:46/255.0
                                        green:204/255.0
                                         blue:113/255.0
                                        alpha:0.5];
    }
    return responseColor;
}

+ (UIColor*)requestColor {
    static UIColor* requestColor = nil;
    if (!requestColor) {
        requestColor = [UIColor colorWithRed:52/255.0
                                       green:152/255.0
                                        blue:219/255.0
                                       alpha:0.5];
    }
    return requestColor;
}

+ (UIColor*)systemColor {
    static UIColor* systemColor = nil;
    if (!systemColor) {
        systemColor = [UIColor colorWithRed:236/255.0
                                      green:240/255.0
                                       blue:241/255.0
                                      alpha:0.5];
    }
    return systemColor;
}

#pragma mark - RBLogInfo's Response
+ (UIColor*)successColor {
    static UIColor* successColor = nil;
    if (!successColor) {
        successColor = [UIColor colorWithRed:46/255.0
                                       green:204/255.0
                                        blue:113/255.0
                                       alpha:0.5];
    }
    return successColor;
}

+ (UIColor*)warningColor {
    static UIColor* warningColor = nil;
    if (!warningColor) {
        warningColor = [UIColor colorWithRed:241/255.0
                                       green:196/255.0
                                        blue:15/255.0
                                       alpha:0.5];

    }
    return warningColor;
}

+ (UIColor*)errorColor {
    static UIColor* errorColor = nil;
    if (!errorColor) {
        errorColor = [UIColor colorWithRed:192/255.0
                                     green:57/255.0
                                      blue:43/255.0
                                     alpha:0.5];
    }
    return errorColor;
}

@end
