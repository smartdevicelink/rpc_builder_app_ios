//
//  RBParamTextField.m
//  RPC Builder
//

#import "RBParamTextField.h"
#import "RBParam.h"

@implementation RBParamTextField

- (instancetype)initWithParam:(RBParam *)param referenceFrame:(CGRect)frame {
    if (self = [super initWithReferenceFrame:frame]) {
        self.parameter = param;
    }
    
    return self;
}

#pragma mark - Getters
- (id)value {
    if ([self.paramType isEqualToString:RBTypeStringKey]) {
        return self.text;
    } else if ([self.paramType isEqualToString:RBTypeIntegerKey]) {
        return @([self.text integerValue]);
    } else if ([self.paramType isEqualToString:RBTypeLongKey]) {
        return @([self.text longLongValue]);
    } else {
        return nil;
    }
}

- (NSString*)paramType {
    return self.parameter.type;
}

- (NSString*)paramName {
    return self.parameter.name;
}

#pragma mark - Setters
- (void)setParameter:(RBParam *)parameter {
    _parameter = parameter;
    
    if ([self.paramType isEqualToString:RBTypeStringKey]) {
        self.keyboardType = UIKeyboardTypeAlphabet;
    } else if ([self.paramType isEqualToString:RBTypeIntegerKey]
               || [self.paramType isEqualToString:RBTypeLongKey]) {
        self.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    if (parameter.defaultValue) {
        self.text = parameter.defaultValue;
    }
    
    if (parameter.minValue
        && parameter.maxValue) {
        self.placeholder = [NSString stringWithFormat:@"%li - %li", (long)parameter.minValue.integerValue, (long)parameter.maxValue.integerValue];
    }
    
    if (parameter.maxLength) {
        self.placeholder = [NSString stringWithFormat:@"%li characters", (long)parameter.maxLength.integerValue];
    }
}

@end
