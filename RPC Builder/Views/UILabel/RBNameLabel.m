//
//  RBNameLabel.m
//  RPC Builder
//

#import "RBNameLabel.h"

#import "RBDeviceInformation.h"
#import "RBParam.h"

#import "UIView+Util.h"

#import "UIAlertController+Minimal.h"

#import "RBParamView.h"

@implementation RBNameLabel

- (instancetype)initWithParam:(RBParam *)param {
    if (self = [self initWithText:param.name isMandatory:param.isMandatory]) {
        _param = param;
    }
    return self;
}

- (instancetype)initWithText:(NSString*)text isMandatory:(BOOL)isMandatory {
    if (self = [super initWithFrame:CGRectZero]) {
        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        NSString* nameString = [text stringByAppendingFormat:@"%@", (isMandatory ? @"*" : @"")];
        nameString = [nameString stringByReplacingOccurrencesOfString:@"(?<!(^|[A-Z]))(?=[A-Z])|(?<!^)(?=[A-Z][a-z]|[0-9])"
                                                           withString:@" $0"
                                                              options:NSRegularExpressionSearch
                                                                range:NSMakeRange(0, nameString.length)].capitalizedString;
        NSDictionary* attributes = @{
                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                     };
        NSMutableAttributedString* mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:nameString
                                                                                                    attributes:attributes];
        if (isMandatory) {
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                            value:[UIColor redColor]
                                            range:NSMakeRange(nameString.length - 1, 1)];
        }
        self.attributedText = mutableAttributedString;
        [self resizeToFit:[RBDeviceInformation maxViewSize]];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(changeViewEnabledState:)];
        [self addGestureRecognizer:gestureRecognizer];
        
        UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                                 action:@selector(presentDescription:)];
        [self addGestureRecognizer:longPressGestureRecognizer];
    }
    return self;
}

- (void)changeViewEnabledState:(id)selector {
    if ([_delegate respondsToSelector:@selector(nameLabel:enabledStateChanged:)]
        && [self.superview isKindOfClass:[RBParamView class]]) {
        BOOL superviewEnabled = [(RBParamView*)self.superview isEnabled];
        [_delegate nameLabel:self
         enabledStateChanged:!superviewEnabled];
    } else {
        NSLog(@"No delegate responding to nameLabel:enabledStateChanged:");
    }
}

- (void)presentDescription:(UILongPressGestureRecognizer*)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    NSString* title = nil;
    NSString* message = nil;
    if (self.param.objectDescription) {
        title = self.param.name;
        message = self.param.objectDescription;
    } else if (self.customDescription.length) {
        title = self.text;
        message = self.customDescription;
    } else {
        title = @"Error";
        message = [NSString stringWithFormat:@"No description available for \"%@\".", self.param.name];
    }
    
    UIAlertController* alertController = [UIAlertController simpleAlertWithTitle:title
                                                                         message:message];
        
    if ([_delegate respondsToSelector:@selector(nameLabel:shouldPresentViewController:)]) {
        [_delegate nameLabel:self shouldPresentViewController:alertController];
    }
    
}

- (void)setConnectedView:(UIView *)connectedView updateFrame:(BOOL)updateFrame {
    _connectedView = connectedView;
    if (updateFrame) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame),
                                CGRectGetMinY(self.frame),
                                CGRectGetWidth(self.bounds),
                                CGRectGetHeight(connectedView.bounds));
    }
}

@end
