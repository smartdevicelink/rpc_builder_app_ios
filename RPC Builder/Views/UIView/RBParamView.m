//
//  RBParamView.m
//  RPC Builder
//

#import "RBParamView.h"

#import "RBParamTextField.h"
#import "RBElementTextField.h"
#import "RBSwitch.h"

#import "UIView+Util.h"

#import "RBParam.h"
#import "RBParser.h"
#import "RBElement.h"

#import "RBStructViewController.h"
#import "RBArrayViewController.h"

@interface RBParamView () <UITextFieldDelegate>

@end

@implementation RBParamView {
    RBNameLabel* _nameLabel;
}

- (instancetype)initWithParam:(RBParam *)param delegate:(id)delegate {
    if (self = [self initWithFrame:CGRectMake(kViewSpacing, 0, 0, 0)]) {
        self.enabled = YES;
        _delegate = delegate;
        _param = param;

        RBNameLabel* nameLabel = [[RBNameLabel alloc] initWithParam:param];
        nameLabel.delegate = self;
        [self addSubview:nameLabel];
        _nameLabel = nameLabel;
        
        BOOL shouldUpdateNameLabel = YES;
        
        _enumObj = [[RBParser sharedParser] enumOfType:param.type];
        _structObj = [[RBParser sharedParser] structOfType:param.type];
        
        if (param.requiresArray) {
            UIImageView* chevronImageView = [self createChevronImageView];
            [self addSubview:chevronImageView];
            
            [self addSelfTapGestureRecognizerWithAction:@selector(arrayAction:)];
            
            _inputView = chevronImageView;
        } else {
            if ([param.type isEqualToString:RBTypeStringKey]
                || [param.type isEqualToString:RBTypeIntegerKey]
                || [param.type isEqualToString:RBTypeFloatKey]
                || [param.type isEqualToString:RBTypeLongKey]) {
                RBParamTextField* textField = [[RBParamTextField alloc] initWithParam:param
                                                                       referenceFrame:nameLabel.frame];
                textField.delegate = self;
                
                [self addSubview:textField];
                _inputView = textField;
            } else if ([param.type isEqualToString:RBTypeBooleanKey]) {
                RBSwitch* booleanSwitch = [[RBSwitch alloc] initWithParam:param
                                                           referenceFrame:nameLabel.frame];
                [booleanSwitch addTarget:self
                                  action:@selector(switchChangedValue:)
                        forControlEvents:UIControlEventValueChanged];
                
                [self addSubview:booleanSwitch];
                _inputView = booleanSwitch;
                
            } else if (_structObj) {
                UIImageView* chevronImageView = [self createChevronImageView];
                [self addSubview:chevronImageView];
                
                [self addSelfTapGestureRecognizerWithAction:@selector(structAction:)];
                
                _inputView = chevronImageView;
            } else if (_enumObj) {
                RBElementTextField* textField = [[RBElementTextField alloc] initWithElements:_enumObj.elements
                                                                              referenceFrame:nameLabel.frame];
                textField.delegate = self;
                [self addSubview:textField];
                _inputView = textField;
            }
        }
        
        [_nameLabel setConnectedView:_inputView
                         updateFrame:shouldUpdateNameLabel];
        
        [self resizeToFit:[RBDeviceInformation maxViewSize]];
    }
    return self;
}


- (void)addTapGestureRecognizerForObject:(id)target action:(SEL)selector {
    UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:selector];
    [target addGestureRecognizer:gestureRecognizer];
}

- (void)addSelfTapGestureRecognizerWithAction:(SEL)selector {
    [self addTapGestureRecognizerForObject:self
                                    action:selector];
}

- (BOOL)addToDictionary:(NSMutableDictionary*)dictionary {
    if (self.isEnabled) {
        if (self.value) {
            dictionary[self.param.name] = self.value;
            return YES;
        }
    } else {
        [dictionary removeObjectForKey:self.param.name];
    }
    return NO;
}


#pragma mark - Actions
- (void)structAction:(id)selector {
    RBStructViewController* viewController = [[RBStructViewController alloc] initWithNibName:@"RBBaseViewController"
                                                                                      bundle:nil];
    [self sdl_presentViewController:viewController];
}

- (void)arrayAction:(id)selector {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    RBArrayViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:@"RBArrayViewController"];
    viewController.param = self.param;
    [self sdl_presentViewController:viewController];
}

- (void)changeViewEnabledState:(id)selector {
    self.enabled = !self.isEnabled;
}

#pragma mark - Getters
- (id)value {
    if (!self.isEnabled) {
        return nil;
    }
    if ([_inputView isKindOfClass:[UIImageView class]]) {
        return nil;
    } else if ([_inputView isKindOfClass:[RBParamTextField class]]) {
        RBParamTextField* textField = (RBParamTextField*)_inputView;
        return [textField value];
    } else if ([_inputView isKindOfClass:[UISwitch class]]) {
        UISwitch* switchObj = (UISwitch*)_inputView;
        return @(switchObj.isOn);
    } else if ([_inputView isKindOfClass:[RBElementTextField class]]) {
        RBElementTextField* textField = (RBElementTextField*)_inputView;
        return textField.text;
    }
    NSLog(@"ERROR");
    return nil;
}

- (UIImageView*)createChevronImageView {
    CGFloat width = 10;
    CGFloat x = [RBDeviceInformation deviceWidth] - (kViewSpacing * 2.0) - width;
    UIImageView* chevronImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x,
                                                                                  CGRectGetMinY(self.frame),
                                                                                  width,
                                                                                  kMinViewHeight)];
    chevronImageView.contentMode = UIViewContentModeScaleAspectFit;
    chevronImageView.image = [UIImage imageNamed:@"chevron"];
    return chevronImageView;
}

#pragma mark - Setters
- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    for (UIView* subview in self.subviews) {
        subview.alpha = enabled ? 1.0f : 0.5f;
    }
}

#pragma mark - Delegates
#pragma mark RBNameLabel
- (void)nameLabel:(RBNameLabel *)nameLabel shouldPresentViewController:(UIViewController *)viewController {
    [self sdl_presentViewController:viewController];
}

- (void)nameLabel:(RBNameLabel *)nameLabel enabledStateChanged:(BOOL)enabled {
    self.enabled = enabled;
}

#pragma mark RBElementTextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.enabled = YES;
    if ([_delegate respondsToSelector:@selector(paramViewShouldPresentPickerView:)]) {
        [_delegate paramViewShouldPresentPickerView:self];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return (BOOL)[_delegate performSelector:@selector(textFieldShouldReturn:) withObject:textField];
    }
    return YES;
}

#pragma mark - Notifications
- (void)switchChangedValue:(id)selector {
    self.enabled = YES;
}

#pragma mark - Private Helpers
- (void)sdl_presentViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[RBBaseViewController class]]) {
        self.enabled = YES;
        RBBaseViewController* baseViewController = (RBBaseViewController*)viewController;
        baseViewController.param = self.param;
        baseViewController.structObj = self.structObj;
    }
    if ([_delegate respondsToSelector:@selector(paramView:shouldPresentViewController:)]) {
        [_delegate paramView:self shouldPresentViewController:viewController];
    }
}

@end
