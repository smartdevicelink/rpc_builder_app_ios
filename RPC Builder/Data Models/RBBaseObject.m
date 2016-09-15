//
//  RBBaseObject.m
//  RPC Builder
//

#import "RBBaseObject.h"

NSString* const RBNameKey = @"name";
NSString* const RBTypeKey = @"type";
NSString* const RBTypeStringKey = @"String";
NSString* const RBTypeIntegerKey = @"Integer";
NSString* const RBTypeLongKey = @"Long";
NSString* const RBTypeDoubleKey = @"Double";
NSString* const RBTypeFloatKey = @"Float";
NSString* const RBTypeBooleanKey = @"Boolean";
NSString* const RBTypeBooleanTrueValue = @"true";
NSString* const RBTypeBooleanFalseValue = @"false";
NSString* const RBDefaultValueKey = @"defvalue";
NSString* const RBIsMandatoryKey = @"mandatory";
NSString* const RBIsArrayKey = @"array";
NSString* const RBMinValueKey = @"minvalue";
NSString* const RBMaxValueKey = @"maxvalue";
NSString* const RBMaxLengthKey = @"maxlength";
NSString* const RBFunctionIDKey = @"functionID";
NSString* const RBMessageTypeKey = @"messagetype";

@interface RBBaseObject ()

@property (nonatomic, strong) NSMutableDictionary* mutableProperties;
@property (nonatomic, strong) NSMutableString* mutableDescription;
@property (nonatomic, strong) NSMutableString* mutableObjectDescription;

@end

@implementation RBBaseObject

+ (instancetype)objectWithDictionary:(NSDictionary*)dictionary {
    return [[[self class] alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        _mutableProperties = [NSMutableDictionary dictionary];
        _mutableDescription = [NSMutableString string];
        _mutableObjectDescription = [NSMutableString string];
        for (NSString* key in dictionary.allKeys) {
            [self handleKey:key
                      value:dictionary[key]];
        }
    }
    return self;
}

#pragma mark - Public Functions
- (void)appendDescription:(NSString *)description {
    if (description.length) {
        description = [description stringByReplacingOccurrencesOfString:@"\\s{2,}"
                                                             withString:@""
                                                                options:NSRegularExpressionSearch
                                                                  range:NSMakeRange(0, description.length)];
        [_mutableObjectDescription appendString:description];
        [_mutableDescription appendString:description];
    }
}

- (void)handleKey:(NSString*)key value:(id)value {
    if ([key isEqualToString:RBNameKey]) {
        _name = value;
    } else {
        _mutableProperties[key] = value;
    }
}

#pragma mark - Getters
- (NSString*)description {
    NSString* properties = self.properties.count ? [NSString stringWithFormat:@", properties: %@", self.properties] : @"";
    NSString* description = _mutableDescription.length ? [NSString stringWithFormat:@", description: %@", _mutableDescription] : @"";
    return [NSString stringWithFormat:@"<%@: %@%@%@>", NSStringFromClass(self.class), _name, properties, description];
}

- (NSString*)objectDescription {
    return _mutableObjectDescription.length ? [_mutableObjectDescription copy] : nil;
}

- (NSDictionary*)properties {
    return [_mutableProperties copy];
}

@end
