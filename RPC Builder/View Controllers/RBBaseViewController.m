//
//  RBBaseViewController.m
//  RPC Builder
//

#import "RBBaseViewController.h"
#import "RBArrayViewController.h"
#import "RBStructViewController.h"

#import "RBDeviceInformation.h"

#import "RBParam.h"

#import "RBParamTextField.h"
#import "RBElementTextField.h"
#import "RBFileView.h"

@interface RBBaseViewController () <RBArrayViewControllerDelegate, RBStructDelegate>

// Strictly used only for scrollView height calculation.
@property (nonatomic, weak) IBOutlet UILabel* requiredLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *requiredLabelBottomConstraint;

@property (nonatomic, weak) RBParamView* presentedParamView;

@end

@implementation RBBaseViewController

@synthesize pickerView = _pickerView;
@synthesize doneToolbar = _doneToolbar;
@synthesize requestDictionary = _requestDictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateView];
    
    UIView* lastView = [self.scrollView.subviews lastObject];
    
    self.scrollView.contentSize = CGSizeMake([RBDeviceInformation deviceWidth],
                                             CGRectGetMaxY(lastView.frame));
    _requiredLabelBottomConstraint.constant = 8 + CGRectGetHeight(self.tabBarController.tabBar.bounds);
}

- (void)updateView { }

- (void)updateRequestsDictionaryFromSubviews {
    for (UIView* view in self.scrollView.subviews) {
        if ([view isKindOfClass:[RBFileView class]]) {
            RBFileView* fileView = (RBFileView*)view;
            if (fileView.fileData) {
                self.bulkData = fileView.fileData;
            } else {
                self.bulkData = nil;
            }
        } else if ([view isKindOfClass:[RBParamView class]]) {
            RBParamView* paramView = (RBParamView*)view;
            [paramView addToDictionary:self.parametersDictionary];
        }
    }
}

- (void)loadParameters:(NSArray*)parameters {
    UIView* lastView = nil;
    
    for (RBParam* param in parameters) {
        id paramValue = self.parametersDictionary[param.name] ?: self.parametersDictionary[self.parameterName];
        if (param.isMandatory) {
            if (!paramValue) {
                self.parametersDictionary[param.name] = param.defaultValue ?: [NSNull null];
            }
        }
        
        RBParamView* view = [param viewWithDelegate:self];
        
        view.enabled = (param.isMandatory || paramValue) || (self.enumObj || self.structObj);
        
        if (paramValue
            &&![paramValue isEqual:[NSNull null]]) {
            UIView* inputView = view.inputView;
            if ([inputView isKindOfClass:[UITextField class]]) {
                UITextField* textField = (UITextField*)inputView;
                if ([paramValue isKindOfClass:[NSNumber class]]) {
                    paramValue = [view.value stringValue];
                } else if ([paramValue isKindOfClass:[NSDictionary class]]) { // This is if paramValue is actually a sub struct.
                    paramValue = paramValue[param.name];
                    if ([paramValue isKindOfClass:[NSNumber class]]) {
                        paramValue = [paramValue stringValue];
                    }
                }
                textField.text = paramValue;
            } else if ([inputView isKindOfClass:[UISwitch class]]) {
                UISwitch* switchObject = (UISwitch*)inputView;
                switchObject.on = [paramValue boolValue];
            }
        }

        if (lastView) {
            CGRect newFrame = view.frame;
            newFrame.origin.y = kParamViewSpacing + CGRectGetMaxY(lastView.frame);
            view.frame = newFrame;
        }
        
        [self.scrollView addSubview:view];
        lastView = view;
    }
}

#pragma mark - Actions
- (void)pickerDoneAction:(id)selector {
    [self.view endEditing:YES];
}

#pragma mark - Getters
- (NSString*)parameterName {
    return self.param.name;
}

- (NSString*)paramType {
    return self.param.type;
}

- (RBSettingsManager*)settingsManager {
    return [RBSettingsManager sharedManager];
}

- (SDLManager*)sdlManager {
    return [SDLManager sharedManager];
}

- (NSMutableDictionary*)requestDictionary {
    if (!_requestDictionary) {
        _requestDictionary = [@{} mutableCopy];
    }
    _requestDictionary[@"parameters"] = self.parametersDictionary;
    _requestDictionary[@"name"] = self.title;
    
    return _requestDictionary;
}

- (NSMutableDictionary*)parametersDictionary {
    if (!_parametersDictionary) {
        _parametersDictionary = [@{} mutableCopy];
    }
    return _parametersDictionary;
}

#pragma mark - Setters
- (void)setRequestDictionary:(NSMutableDictionary *)requestDictionary {
    _requestDictionary = requestDictionary;
    if (!self.parametersDictionary.count) {
        NSMutableDictionary* parametersDictionary = [requestDictionary[@"parameters"] mutableCopy];
        self.parametersDictionary = parametersDictionary;
    }
}

#pragma mark - Overrides
- (CGFloat)scrollViewBottomOffset {
    return CGRectGetHeight(_requiredLabel.frame) + CGRectGetHeight(self.tabBarController.tabBar.bounds);
}

#pragma mark - Delegates
#pragma mark RBArrayViewController
- (void)arrayViewControllerWillDismiss:(RBArrayViewController *)viewController withCount:(NSUInteger)count {
    _presentedParamView.enabled = (count > 0);
    _presentedParamView = nil;
}

#pragma mark RBStructViewController
- (void)structViewController:(RBStructViewController *)viewController didCreateStruct:(NSDictionary *)structDictionary {
    self.parametersDictionary[viewController.parameterName] = structDictionary;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITextField
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isKindOfClass:[RBParamTextField class]]) {
        RBParamTextField* rsTextField = (RBParamTextField*)textField;
        self.parametersDictionary[rsTextField.paramName] = rsTextField.value;
    }
}

#pragma mark ParamView
- (void)paramView:(RBParamView *)view shouldPresentViewController:(UIViewController *)viewController {
    _presentedParamView = view;
    [self.view endEditing:YES];
    if ([viewController isKindOfClass:[RBBaseViewController class]]) {
        RBBaseViewController* baseViewController = (RBBaseViewController*)viewController;
        baseViewController.requestDictionary = self.requestDictionary;
        baseViewController.parametersDictionary = self.parametersDictionary;
        if ([viewController isKindOfClass:[RBArrayViewController class]]) {
            RBArrayViewController* arrayViewController = (RBArrayViewController*)viewController;
            arrayViewController.delegate = self;
        } else if ([viewController isKindOfClass:[RBStructViewController class]]) {
            RBStructViewController* structViewController = (RBStructViewController*)viewController;
            structViewController.delegate = self;
        }
    }

    if ([viewController isKindOfClass:[UIAlertController class]]) {
        [self presentViewController:viewController
                           animated:YES
                         completion:nil];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        [self presentViewController:viewController
                           animated:YES
                         completion:nil];
    } else {
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }
}

- (void)paramViewShouldPresentPickerView:(RBParamView *)view  {
    if ([view.inputView isKindOfClass:[RBElementTextField class]]) {
        RBElementTextField* textView = (RBElementTextField*)view.inputView;
        
        if (![textView.inputView isKindOfClass:[UIPickerView class]]) {
            textView.inputView = self.pickerView;
            textView.inputAccessoryView = self.doneToolbar;
        }
    }
}

#pragma mark - Private
#pragma mark Getters
- (UIPickerView*)pickerView {
    if (!_pickerView) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
        _pickerView = pickerView;
    }
    return _pickerView;
}

- (UIToolbar*)doneToolbar {
    if (!_doneToolbar) {
        UIToolbar* doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                             0,
                                                                             [RBDeviceInformation deviceWidth],
                                                                             44)];
        UIBarButtonItem* flexibleWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
        UIBarButtonItem* doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(pickerDoneAction:)];
        doneToolbar.items = @[flexibleWidth, doneItem];
        _doneToolbar = doneToolbar;
    }
    return _doneToolbar;
}

@end
