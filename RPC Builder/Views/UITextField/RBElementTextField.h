//
//  RBElementTextField.h
//  RPC Builder
//

#import "RBTextField.h"

@class RBElement;

@interface RBElementTextField : RBTextField <UIPickerViewDataSource, UIPickerViewDelegate>

- (instancetype)initWithElements:(NSArray*)elements referenceFrame:(CGRect)frame;

@property (nonatomic, strong) NSArray* elements;
@property (nonatomic, weak) id currentElement;

@end
