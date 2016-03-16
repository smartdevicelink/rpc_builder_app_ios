//
//  RBStruct.m
//  RPC Builder
//

#import "RBStruct.h"

@interface RBStruct ()

@property (nonatomic, strong) NSMutableArray* mutableParams;

@end

@implementation RBStruct

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        _mutableParams = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public
- (void)addParameter:(RBParam *)param {
    [_mutableParams addObject:param];
}

#pragma mark - Getters
- (NSString*)description {
    NSMutableString* mutableDescription = [super.description mutableCopy];
    if (self.parameters.count) {
        [mutableDescription insertString:[NSString stringWithFormat:@", parameters: %@", self.parameters]
                                 atIndex:mutableDescription.length-1];
    }
    return [mutableDescription copy];
}

- (NSArray*)parameters {
    return [_mutableParams copy];
}

@end
