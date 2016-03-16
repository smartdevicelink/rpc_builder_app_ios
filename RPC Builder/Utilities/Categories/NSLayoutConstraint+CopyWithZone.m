//
//  NSLayoutConstraint+CopyWithZone.m
//  RPC Builder
//

#import "NSLayoutConstraint+CopyWithZone.h"

@implementation NSLayoutConstraint (CopyWithZone)

- (instancetype)copyWithZone:(NSZone *)zone {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.firstItem
                                                                  attribute:self.firstAttribute
                                                                  relatedBy:self.relation
                                                                     toItem:self.secondItem
                                                                  attribute:self.secondAttribute
                                                                 multiplier:self.multiplier
                                                                   constant:self.constant];
    return constraint;
}

@end
