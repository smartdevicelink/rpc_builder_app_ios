//
//  NSString+Regex.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 6/7/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "NSString+Regex.h"

@implementation NSString (Regex)

- (NSString*)firstStringMatchUsingRegex:(NSRegularExpression*)regex {
    if (!self.length) {
        return nil;
    }
    NSTextCheckingResult* match = [regex firstMatchInString:self
                                                    options:NSMatchingReportCompletion
                                                      range:NSMakeRange(0, self.length)];
    
    NSRange matchRange = ([match numberOfRanges] > 1) ? [match rangeAtIndex:1] : [match range];
    
    return [self substringWithRange:matchRange];
}

@end
