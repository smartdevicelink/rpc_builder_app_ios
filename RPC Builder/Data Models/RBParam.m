//
//  RBParam.m
//  RPC Builder
//

#import "RBParam.h"
#import "RBParamView.h"

@implementation RBParam

#pragma mark - Public
- (RBParamView*)viewWithDelegate:(id)delegate {
    return [[RBParamView alloc] initWithParam:self
                                     delegate:delegate];
}

#pragma mark - Overrides
- (void)handleKey:(NSString*)key value:(id)value {
    if ([key isEqualToString:RBTypeKey]) {
        _type = value;
    } else if ([key isEqualToString:RBDefaultValueKey]) {
        _defaultValue = value;
    } else if ([key isEqualToString:RBIsMandatoryKey]) {
        _isMandatory = [value isEqualToString:RBTypeBooleanTrueValue];
    } else if ([key isEqualToString:RBIsArrayKey]) {
        _requiresArray = [value isEqualToString:RBTypeBooleanTrueValue];
    } else if ([key isEqualToString:RBMinValueKey]) {
        _minValue = value;
    } else if ([key isEqualToString:RBMaxValueKey]) {
        _maxValue = value;
    } else if ([key isEqualToString:RBMaxLengthKey]) {
        _maxLength = value;
    } else {
        [super handleKey:key
                   value:value];
    }
}

#pragma mark - Getters
- (NSString*)description {
    NSMutableString* mutableDescription = [super.description mutableCopy];
    NSString* elements = self.elements.count ? [NSString stringWithFormat:@", elements: %@", self.elements] : @"";
    NSString* defaultValue = _defaultValue.length ? [NSString stringWithFormat:@", default: %@", _defaultValue] : @"";
    [mutableDescription insertString:[NSString stringWithFormat:@", type: %@%@%@, mandatory: %@, array: %@", _type, defaultValue, elements, _isMandatory ? @"YES" : @"NO", _requiresArray ? @"YES" : @"NO"] atIndex:mutableDescription.length-1];
    return [mutableDescription copy];
}

@end
