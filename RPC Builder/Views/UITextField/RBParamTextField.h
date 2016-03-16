//
//  RBParamTextField.h
//  RPC Builder
//

#import "RBTextField.h"

@class RBParam;

@interface RBParamTextField : RBTextField

- (instancetype)initWithParam:(RBParam*)param referenceFrame:(CGRect)frame;

@property (nonatomic, weak) RBParam* parameter;
@property (nonatomic, readonly) NSString* paramType;
@property (nonatomic, readonly) NSString* paramName;

@property (nonatomic, readonly) id value;

@end
