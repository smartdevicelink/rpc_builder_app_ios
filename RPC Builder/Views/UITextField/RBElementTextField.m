//
//  RBElementTextField.m
//  RPC Builder
//

#import "RBElementTextField.h"
#import "RBElement.h"

@implementation RBElementTextField {
    NSUInteger _currentElementIndex;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self sdl_commonInitializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self sdl_commonInitializer];
    }
    return self;
}

- (instancetype)initWithElements:(NSArray*)elements referenceFrame:(CGRect)frame {
    if (self = [super initWithReferenceFrame:frame]) {
        self.elements = elements;
        self.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)setCurrentElement:(id)currentElement {
    _currentElement = currentElement;
    _currentElementIndex = [self.elements indexOfObject:currentElement];
    self.text = [self sdl_stringForElement:currentElement];
}

- (void)setElements:(NSArray *)elements {
    _elements = elements;
    _currentElementIndex = 0;
    self.currentElement = elements[_currentElementIndex];
}

// This override fixes an issue if the user scrolls quickly and quits before UIPickerView's
// pickerView:didSelectRow:inComponent: is called.
- (BOOL)resignFirstResponder {
    if ([self.inputView isKindOfClass:[UIPickerView class]]) {
        UIPickerView* pickerView = (UIPickerView*)self.inputView;
        NSUInteger selectedIndexPath = [pickerView selectedRowInComponent:0];
        self.currentElement = _elements[selectedIndexPath];
    }
    return [super resignFirstResponder];
}

#pragma mark - Delegates
#pragma mark UIPickerView
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentElement = self.elements[row];
}

#pragma mark - Data Source
#pragma mark UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.elements.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    id element = self.elements[row];
    return [self sdl_stringForElement:element];
}

#pragma mark - Notifications
#pragma mark UITextField
- (void)textFieldDidBeginEditing:(NSNotification*)notification {
    if (notification.object == self) {
        if ([self.inputView isKindOfClass:[UIPickerView class]]) {
            UIPickerView* pickerView = (UIPickerView*)self.inputView;
            pickerView.delegate = self;
            pickerView.dataSource = self;
            [pickerView selectRow:_currentElementIndex
                      inComponent:0
                         animated:YES];
        }
    }
}

#pragma mark - Private Helpers
- (void)sdl_commonInitializer {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidBeginEditing:)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
}

- (NSString*)sdl_stringForElement:(id)element {
    if ([element isKindOfClass:[RBElement class]]) {
        return [(RBElement*)element name];
    } else if ([element isKindOfClass:[NSString class]]) {
        return element;
    }
    
    NSAssert(NO, @"Unknown type of element");
    return nil;
}

@end
