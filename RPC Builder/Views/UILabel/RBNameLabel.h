//
//  RBNameLabel.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

@class RBNameLabel;

@protocol RBNameLabelDelegate <NSObject>

- (void)nameLabel:(RBNameLabel*)nameLabel shouldPresentViewController:(UIViewController*)viewController;
- (void)nameLabel:(RBNameLabel *)nameLabel enabledStateChanged:(BOOL)enabled;

@end

@class RBParam;

@interface RBNameLabel : UILabel

- (instancetype)initWithParam:(RBParam*)param;
- (instancetype)initWithText:(NSString*)text isMandatory:(BOOL)isMandatory;

- (void)setConnectedView:(UIView *)connectedView updateFrame:(BOOL)updateFrame;

@property (nonatomic, readonly) RBParam* param;

@property (nonatomic, weak) NSString* customDescription;

@property (nonatomic, readonly) UIView* connectedView;

@property (weak) id<RBNameLabelDelegate> delegate;

@end
