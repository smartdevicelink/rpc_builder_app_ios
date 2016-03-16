//
//  RBTextField.m
//  RPC Builder
//

#import "RBTextField.h"

#import "UIView+Util.h"

@implementation RBTextField

- (instancetype)initWithReferenceFrame:(CGRect)frame {
    if (self = [self initWithFrame:CGRectZero]) {
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.returnKeyType = UIReturnKeyDone;
        [self bottomAlignmentWithReferenceRect:frame];
    }
    
    return self;
}

@end
