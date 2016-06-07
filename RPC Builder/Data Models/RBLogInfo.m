//
//  RBLogInfo.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/14/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBLogInfo.h"

#import "NSString+Regex.h"
#import "UIColor+Util.h"

static NSString* const RBLogInfoTypeStringNotification = @"(notification)";
static NSString* const RBLogInfoTypeStringResponse = @"(response)";
static NSString* const RBLogInfoTypeStringRequest = @"(request)";

static NSString* const RBLogInfoResultTypeSuccess = @"SUCCESS";
static NSString* const RBLogInfoResultTypeAborted = @"ABORTED";
static NSString* const RBLogInfoResultTypeTimedOut = @"TIMED_OUT";
static NSString* const RBLogInfoResultTypeWarnings = @"WARNINGS";

@interface RBLogInfo ()

@property (nonatomic, readonly) NSRegularExpression* logTypeRegex;
@property (nonatomic, readonly) NSRegularExpression* resultTypeRegex;

@property (nonatomic, readonly) NSDateFormatter* dateFormatter;

@end

@implementation RBLogInfo

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
            _resultString = [_message firstStringMatchUsingRegex:self.resultTypeRegex];
            if ([_resultString isEqualToString:RBLogInfoResultTypeSuccess]) {
                _resultColor = [UIColor successColor];
            } else if ([_resultString isEqualToString:RBLogInfoResultTypeAborted]
                       || [_resultString isEqualToString:RBLogInfoResultTypeTimedOut]
                       || [_resultString isEqualToString:RBLogInfoResultTypeWarnings]) {
                _resultColor = [UIColor warningColor];
            } else {
                _resultColor = [UIColor errorColor];
            }
        } else {
            _message = @"";
        }
        
        NSString* logTypeString = [_title firstStringMatchUsingRegex:self.logTypeRegex];
        
        if ([logTypeString isEqualToString:RBLogInfoTypeStringNotification]) {
            _type = RBLogInfoTypeNotification;
            _typeColor = [UIColor notificationColor];
        } else if ([logTypeString isEqualToString:RBLogInfoTypeStringRequest]) {
            _type = RBLogInfoTypeRequest;
            _typeColor = [UIColor requestColor];
        } else if ([logTypeString isEqualToString:RBLogInfoTypeStringResponse]) {
            _type = RBLogInfoTypeResponse;
            _typeColor = [UIColor responseColor];
        } else {
            _type = RBLogInfoTypeSystem;
            _typeColor = [UIColor systemColor];
        }
    }
    return self;
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

- (NSRegularExpression*)logTypeRegex {
    static NSRegularExpression* regularExpression = nil;
    if (!regularExpression) {
        NSError* error = nil;
        regularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\(\\w*\\)"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
        if (error) {
            NSLog(@"Regex error: %@", error.localizedDescription);
        }
    }
    return regularExpression;
}

- (NSRegularExpression*)resultTypeRegex {
    static NSRegularExpression* regularExpression = nil;
    if (!regularExpression) {
        NSError* error = nil;
        regularExpression = [NSRegularExpression regularExpressionWithPattern:@"resultCode = \"?(\\w*)\"?;"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
        if (error) {
            NSLog(@"Regex error: %@", error.localizedDescription);
        }
    }
    return regularExpression;
}

@end
