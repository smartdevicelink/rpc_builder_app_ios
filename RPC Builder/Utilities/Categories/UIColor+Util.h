//
//  UIColor+Util.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 6/7/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)

// RBLogInfo's Type
+ (UIColor*)notificationColor;
+ (UIColor*)requestColor;
+ (UIColor*)responseColor;
+ (UIColor*)systemColor;

// RBLogInfo's Response
+ (UIColor*)successColor;
+ (UIColor*)warningColor;
+ (UIColor*)errorColor;

@end
