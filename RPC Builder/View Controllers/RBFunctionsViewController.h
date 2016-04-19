//
//  RBFunctionsViewController.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

#import "RBFunctionViewController.h"

#import "RBFunction.h"

@interface RBFunctionsViewController : UITableViewController

+ (RBFunctionViewController*)viewControllerForFunction:(RBFunction*)function;

@end


