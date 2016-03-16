//
//  RBScrollViewController.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

@interface RBScrollViewController : UIViewController

@property (nonatomic, readonly) NSNotificationCenter* notificationCenter;

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* scrollViewBottomConstraint;

/*
 *
 * Override when scrollView is not anchored to bottom of parent view.
 *
 */
@property (nonatomic, readonly) CGFloat scrollViewBottomOffset;

@end
