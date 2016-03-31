//
//  RBBaseObject.h
//  RPC Builder
//

#import <Foundation/Foundation.h>

extern NSString* const RBNameKey;
extern NSString* const RBTypeKey;
extern NSString* const RBTypeStringKey;
extern NSString* const RBTypeIntegerKey;
extern NSString* const RBTypeLongKey;
extern NSString* const RBTypeFloatKey;
extern NSString* const RBTypeBooleanKey;
extern NSString* const RBTypeBooleanTrueValue;
extern NSString* const RBTypeBooleanFalseValue;
extern NSString* const RBDefaultValueKey;
extern NSString* const RBIsMandatoryKey;
extern NSString* const RBIsArrayKey;
extern NSString* const RBMinValueKey;
extern NSString* const RBMaxValueKey;
extern NSString* const RBMaxLengthKey;
extern NSString* const RBFunctionIDKey;
extern NSString* const RBMessageTypeKey;

@interface RBBaseObject : NSObject

+ (instancetype)objectWithDictionary:(NSDictionary*)dictionary;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (void)handleKey:(NSString*)key value:(id)value;

- (void)appendDescription:(NSString *)description;

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) NSDictionary* properties;
@property (nonatomic, readonly) NSString* objectDescription;

@end
