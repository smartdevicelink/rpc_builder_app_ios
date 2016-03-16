//
//  RBFunction.m
//  RPC Builder
//

#import "RBFunction.h"

@interface RBFunction ()

@property (nonatomic, strong, readonly) NSArray* UIFunctionNames;
@property (nonatomic, strong, readonly) NSArray* bulkDataFunctionNames;

@end

@implementation RBFunction 

@synthesize image = _image;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        _requiresBulkData = [self.bulkDataFunctionNames containsObject:self.name];
    }
    return self;
}

#pragma mark - Overrides
- (void)handleKey:(NSString*)key value:(id)value {
    if ([key isEqualToString:RBFunctionIDKey]) {
        _functionID = value;
    } else if ([key isEqualToString:RBMessageTypeKey]) {
        _messageType = value;
    } else {
        [super handleKey:key
                   value:value];
    }
}

#pragma mark - Getters
- (NSString*)description {
    NSMutableString* mutableDescription = [super.description mutableCopy];
    NSString* parameters = self.parameters.count ? [NSString stringWithFormat:@", parameters: %@", self.parameters] : @"";
    [mutableDescription insertString:[NSString stringWithFormat:@", functionID: %@, messageType: %@%@", _functionID, _messageType, parameters] atIndex:mutableDescription.length-1];
    return [mutableDescription copy];
}

- (UIImage*)image {
    if (!_image) {
        if ([self.name hasPrefix:@"Add"]
            || [self.name hasPrefix:@"Create"]) {
            _image = [UIImage imageNamed:@"add"];
        } else if ([self.name hasPrefix:@"Delete"]) {
            _image = [UIImage imageNamed:@"delete"];
        } else if ([self.name hasPrefix:@"Subscribe"]) {
            _image = [UIImage imageNamed:@"subscribe"];
        } else if ([self.name hasPrefix:@"Un"]) {
            _image = [UIImage imageNamed:@"unsubscribe"];
        } else if ([self.name hasPrefix:@"Set"]
                   || [self.name hasPrefix:@"Alert"]
                   || [self.UIFunctionNames containsObject:self.name]) {
            _image = [UIImage imageNamed:@"ui"];
        } else {
            _image = [UIImage imageNamed:@"other"];
        }
    }
    return _image;
}

#pragma - mark Private
- (NSArray*)UIFunctionNames {
    static NSArray* UIFunctionNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!UIFunctionNames) {
            UIFunctionNames = @[
                        @"Show",
                        @"SendLocation",
                        @"Slider",
                        @"Speak",
                        @"PerformInteraction",
                        @"PerformAudioPassThru",
                        @"ScrollableMessage"
                        ];
        }
    });
    return UIFunctionNames;
}

- (NSArray*)bulkDataFunctionNames {
    static NSArray* bulkDataFunctionNames = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!bulkDataFunctionNames) {
            bulkDataFunctionNames = @[@"PutFile"];
        }
    });
    return bulkDataFunctionNames;
}

@end
