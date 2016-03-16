//
//  RBScrollViewController.m
//  RPC Builder
//

#import "RBScrollViewController.h"

@interface RBScrollViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSLayoutConstraint* originalBottomConstraint;

@end

@implementation RBScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(keyboardWillHideAction:)
                                    name:UIKeyboardWillHideNotification
                                  object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(keyboardWillShowAction:)
                                    name:UIKeyboardWillChangeFrameNotification
                                  object:nil];
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

#pragma mark - Actions
- (void)keyboardWillHideAction:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    NSTimeInterval animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationCurve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:animationCurve
                     animations:^{
                         _scrollViewBottomConstraint.constant = _originalBottomConstraint.constant;
                     } completion:nil];
}

- (void)keyboardWillShowAction:(NSNotification*)notification {
    if (!_originalBottomConstraint) {
        _originalBottomConstraint = [_scrollViewBottomConstraint copy];
    }
    NSDictionary* info = [notification userInfo];
    CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
    
    NSTimeInterval animationDuration = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions animationCurve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0f
                        options:animationCurve
                     animations:^{
        _scrollViewBottomConstraint.constant = _originalBottomConstraint.constant + keyboardHeight - self.scrollViewBottomOffset;
    } completion:nil];
}

#pragma mark - Getters
- (NSNotificationCenter*)notificationCenter {
    return [NSNotificationCenter defaultCenter];
}

- (CGFloat)scrollViewBottomOffset {
    return 0.0f;
}

#pragma mark - Delegates
#pragma mark UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
