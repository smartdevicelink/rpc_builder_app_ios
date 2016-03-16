//
//  RBSpecFilesViewController.h
//  RPC Builder
//

#import <UIKit/UIKit.h>
#import "RBSpecFile.h"

@class RBSpecFilesViewController;

@protocol RBSpecFilesViewControllerDelegate <NSObject>

- (void)specFilesViewController:(RBSpecFilesViewController*)viewController didSelectSpecFile:(RBSpecFile*)specFile;

@end

@interface RBSpecFilesViewController : UIViewController

@property (weak) id<RBSpecFilesViewControllerDelegate> delegate;

@end
