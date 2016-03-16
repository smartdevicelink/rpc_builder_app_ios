//
//  RBArrayViewController.h
//  RPC Builder
//

#import "RBBaseViewController.h"

@class RBArrayViewController;

@protocol RBArrayViewControllerDelegate <NSObject>

- (void)arrayViewControllerWillDismiss:(RBArrayViewController*)viewController withCount:(NSUInteger)count;

@end

@interface RBArrayViewController : RBBaseViewController

@property (weak) id<RBArrayViewControllerDelegate> delegate;

@end
