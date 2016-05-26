//
//  RBParamView.h
//  RPC Builder
//

#import "RBView.h"

#import "RBParam.h"

#import "RBDeviceInformation.h"
#import "RBNameLabel.h"

@class RBParamView;

@protocol RBParamViewDelegate <NSObject>

- (void)paramView:(RBParamView*)view shouldPresentViewController:(UIViewController*)viewController;
- (void)paramViewShouldPresentPickerView:(RBParamView *)view;

@end



@class RBStruct;
@class RBEnum;
@class RBElement;

@interface RBParamView : RBView <RBNameLabelDelegate>

- (instancetype)initWithParam:(RBParam*)param delegate:(id<RBParamViewDelegate>)delegate;

- (void)addTapGestureRecognizerForObject:(id)target action:(SEL)selector;
- (void)addSelfTapGestureRecognizerWithAction:(SEL)selector;

- (UIImageView*)createChevronImageView;

- (BOOL)addToDictionary:(NSMutableDictionary*)dictionary;

@property (nonatomic, readonly) RBParam* param;
@property (nonatomic, readonly) RBStruct* structObj;
@property (nonatomic, readonly) RBEnum* enumObj;

@property (nonatomic, readonly) UIView* inputView;

@property (nonatomic, getter=isEnabled) BOOL enabled;

@property (nonatomic, readonly) id value;

@property (weak) id<RBParamViewDelegate> delegate;

@end
