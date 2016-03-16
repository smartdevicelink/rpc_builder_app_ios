//
//  RBStructViewController.m
//  RPC Builder
//

#import "RBStructViewController.h"
#import "RBArrayViewController.h"

#import "RBStruct.h"

@implementation RBStructViewController

- (void)updateView {
    self.title = self.structObj.name;

    UIBarButtonItem* saveBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                   target:self
                                                                                   action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = saveBarButton;
    
    [self loadParameters:self.structObj.parameters];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[RBArrayViewController class]]) {
        RBArrayViewController* viewController = segue.destinationViewController;
        viewController.parametersDictionary = self.parametersDictionary;
    }
}

#pragma mark - Actions
- (void)saveAction:(id)selector {
    if ([_delegate respondsToSelector:@selector(structViewController:didCreateStruct:)]) {
        [_delegate structViewController:self
                        didCreateStruct:[self sdl_parametersDictionaryFromSubviews]];
    } else {
        self.parametersDictionary[self.param.name] = [self sdl_parametersDictionaryFromSubviews];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private
- (NSDictionary*)sdl_parametersDictionaryFromSubviews {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    for (UIView* view in self.scrollView.subviews) {
        if ([view isKindOfClass:[RBParamView class]]) {
            RBParamView* paramView = (RBParamView*)view;
            if (paramView.value) {
                parameters[paramView.param.name] = paramView.value;
            }
        }
    }
    return [parameters copy];
}

#pragma mark - Overrides
// We are placing this here because we actually don't want to use RBBaseViewController's implementation.
- (void)textFieldDidEndEditing:(UITextField *)textField { }

@end
