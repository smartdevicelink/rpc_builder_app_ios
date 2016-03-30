//
//  RBModuleViewController.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBModuleViewController : UIViewController

/*
 *  Name of the module. Will be shown in list of modules, as well as module's view 
 *  controller.
 */
+ (NSString*)moduleTitle;

/*
 *  Description of the module. Will be shown in list of modules.
 */
+ (NSString*)moduleDescription;

/*
 *  Name of an image that will represent the module. It will be used in the list of modules.
 */
+ (NSString*)moduleImageName;

/*
 *  Image used to represent module in a list.
 */
+ (UIImage*)moduleImage;

/*
 *  Array of all available module class names.
 */
+ (NSArray*)moduleClassNames;

/*
 *  Static reference to subclasses' view controller. Will only construct view controller
 *  once.
 */
+ (RBModuleViewController*)viewController;

@end
