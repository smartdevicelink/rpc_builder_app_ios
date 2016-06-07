//
//  RBLogInfo.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/14/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RBLogInfoType) {
    RBLogInfoTypeSystem,
    RBLogInfoTypeNotification,
    RBLogInfoTypeRequest,
    RBLogInfoTypeResponse
};

@interface RBLogInfo : NSObject

+ (instancetype)logInfoWithString:(NSString*)string;

- (instancetype)initWithString:(NSString*)string;

@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSString* dateString;
@property (nonatomic, readonly) NSString* message;

@property (nonatomic, readonly) RBLogInfoType type;
@property (nonatomic, readonly) UIColor* typeColor;

@property (nonatomic, readonly) NSString* resultString;
@property (nonatomic, readonly) UIColor* resultColor;

@end
