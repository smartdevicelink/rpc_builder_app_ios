//
//  RBParam.h
//  RPC Builder
//

#import "RBEnum.h"
#import <UIKit/UIKit.h>

@class RBParamView;

@interface RBParam : RBEnum

@property (nonatomic, readonly) NSString* type;
@property (nonatomic, readonly) NSString* defaultValue;
@property (nonatomic, readonly) NSNumber* minValue;
@property (nonatomic, readonly) NSNumber* maxValue;
@property (nonatomic, readonly) NSNumber* maxLength;
@property (nonatomic, readonly) BOOL requiresArray;
@property (nonatomic, readonly) BOOL isMandatory;

- (RBParamView*)viewWithDelegate:(id)delegate;

@end
