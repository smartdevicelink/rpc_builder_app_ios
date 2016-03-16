//
//  RBLogInfo.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/14/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBLogInfo.h"

@interface RBLogInfo ()

@property (nonatomic, readonly) NSDateFormatter* dateFormatter;

@end

@implementation RBLogInfo

@synthesize color = _color;

+ (instancetype)logInfoWithString:(NSString*)string {
    return [[RBLogInfo alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString*)string {
    if (self = [super init]) {
        _dateString = [self.dateFormatter stringFromDate:[NSDate date]];
        NSString* strippedInfo = [string stringByReplacingOccurrencesOfString:@"[ \\t]+"
                                                                   withString:@" "
                                                                      options:NSRegularExpressionSearch
                                                                        range:NSMakeRange(0, string.length)];
        NSArray* components = [strippedInfo componentsSeparatedByString:@"\n"];
        _title = [components firstObject];
        if (components.count > 1) {
            _message = [[components subarrayWithRange:NSMakeRange(1, components.count - 1)] componentsJoinedByString:@"\n"];
        } else {
            _message = @"";
        }
    }
    return self;
}

#pragma mark - Getters
- (UIColor*)color {
    if (!_color) {
        if ([self.title hasSuffix:@"(request)"]) {
            _color = [UIColor colorWithRed:52/255.0
                                     green:152/255.0
                                      blue:219/255.0
                                     alpha:0.5];
        } else if ([self.title hasSuffix:@"(response)"]) {
            _color = [UIColor colorWithRed:46/255.0
                                     green:204/255.0
                                      blue:113/255.0
                                     alpha:0.5];
        } else if ([self.title hasSuffix:@"(notification)"]) {
            _color = [UIColor colorWithRed:241/255.0
                                     green:196/255.0
                                      blue:15/255.0
                                     alpha:0.5];
        } else {
            _color = [UIColor colorWithRed:236/255.0
                                     green:240/255.0
                                      blue:241/255.0
                                     alpha:0.5];
        }
    }
    return _color;
}

#pragma mark - Private
#pragma mark Getters
- (NSDateFormatter*)dateFormatter {
    static NSDateFormatter* dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm:ss.SS";
    }
    return dateFormatter;
}

@end
