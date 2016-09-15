//
//  NSObject+Swizzle.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 9/15/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "NSObject+Swizzle.h"

#import <objc/runtime.h>
#import "RBParser.h"

@implementation NSObject (Swizzle)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        swizzleForClass(@"SDLFunctionID", @selector(getFunctionID:), @selector(xxx_getFunctionID:));
        swizzleForClass(@"SDLFunctionID", @selector(getFunctionName:), @selector(xxx_getFunctionName:));
#pragma clang diagnostic pop
    });
}

- (NSNumber*)xxx_getFunctionID:(NSString *)functionName {
    NSNumber* functionID = nil;
    for (RBFunction* function in [[RBParser sharedParser] functions]) {
        if ([function.name isEqualToString:functionName]) {
            NSString* functionIDName = function.functionID;
            for (RBElement* element in [[RBParser sharedParser] elements]) {
                if ([element.name isEqualToString:functionIDName]) {
                    functionID = [[self numberFormatter] numberFromString:element.properties[@"value"]];
                    break;
                }
            }
            
            if (functionID) {
                break;
            }
        }
    }
    return functionID;
}

- (NSString*)xxx_getFunctionName:(int)functionID {
    NSString* functionName = nil;
    for (RBElement* element in [[RBParser sharedParser] elements]) {
        if (element.properties.count == 0) {
            continue;
        }
        NSString* elementValue = element.properties[@"value"];
        if ([elementValue isEqualToString:[NSString stringWithFormat:@"%i", functionID]]) {
            for (RBFunction* function in [[RBParser sharedParser] functions]) {
                if ([function.functionID isEqualToString:element.name]) {
                    functionName = function.name;
                    break;
                }
            }
            if (functionName) {
                break;
            }
        }
    }
    return functionName;
}


#pragma mark - Helpers
BOOL swizzleForClass(NSString* className, SEL methodName, SEL swizzleMethodName) {
    Class class = NSClassFromString(className);
    
    if (!class) {
        return NO;
    }
    
    SEL originalSelector = methodName;
    SEL swizzledSelector = swizzleMethodName;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

    return YES;
}


- (NSNumberFormatter*)numberFormatter {
    static NSNumberFormatter* numberFormatter = nil;
    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    return numberFormatter;
}

@end
