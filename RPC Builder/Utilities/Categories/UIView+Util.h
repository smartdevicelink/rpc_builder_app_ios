//
//  UIView+Resize.h
//  RPC Builder
//

#import <UIKit/UIKit.h>
#import "RBView.h"
#import "RBDeviceInformation.h"

@interface UIView (Util)

- (void)resizeToFit:(CGSize)size;

- (void)rightAlignmentWithReferenceRect:(CGRect)referenceRect;

- (void)bottomAlignmentWithReferenceRect:(CGRect)referenceRect;

- (void)copyParentConstraintsToView:(UIView*)view;

@end
