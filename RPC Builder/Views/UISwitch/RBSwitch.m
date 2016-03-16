//
//  RBSwitch.m
//  RPC Builder
//

#import "RBSwitch.h"

#import "RBParam.h"

#import "UIView+Util.h"

@implementation RBSwitch

- (instancetype)initWithParam:(RBParam*)param referenceFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
        [self rightAlignmentWithReferenceRect:frame];
        if (param.defaultValue) {
            if ([param.defaultValue isEqualToString:RBTypeBooleanTrueValue]) {
                self.on = YES;
            } else if ([param.defaultValue isEqualToString:RBTypeBooleanFalseValue]) {
                self.on = NO;
            }
        }
    }
    return self;
}

@end
