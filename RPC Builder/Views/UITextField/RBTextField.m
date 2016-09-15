//
//  RBTextField.m
//  RPC Builder
//

#import "RBTextField.h"

#import "UIView+Util.h"

@implementation RBTextField

- (instancetype)initWithReferenceFrame:(CGRect)frame {
    if (self = [self initWithFrame:CGRectZero]) {
        [self bottomAlignmentWithReferenceRect:frame];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.returnKeyType = UIReturnKeyDone;
    }
    
    return self;
}

- (id)copyAs:(Class)copyClass {
    if (![copyClass isSubclassOfClass:[self class]]) {
        return nil;
    }
    id newCopy = [[copyClass alloc] initWithFrame:self.frame];
    [newCopy setDelegate:self.delegate];
    
    return newCopy;
}

@end
