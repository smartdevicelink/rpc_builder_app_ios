//
//  RBEnum.m
//  RPC Builder
//

#import "RBEnum.h"

@interface RBEnum ()

@property (nonatomic, strong) NSMutableArray* mutableElements;

@end

@implementation RBEnum

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super initWithDictionary:dictionary]) {
        _mutableElements = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Functions
- (void)addElement:(RBElement *)element {
    [_mutableElements addObject:element];
}

#pragma mark - Getters
- (NSString*)description {
    NSMutableString* mutableDescription = [super.description mutableCopy];
    if (self.elements.count) {
        [mutableDescription insertString:[NSString stringWithFormat:@", elements: %@", self.elements]
                                 atIndex:mutableDescription.length-1];
    }
    return [mutableDescription copy];
}

- (NSArray*)elements {
    return [_mutableElements copy];
}

@end
