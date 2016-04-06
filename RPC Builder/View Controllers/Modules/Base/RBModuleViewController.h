//
//  RBModuleViewController.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBScrollViewController.h"
#import "UIAlertController+Minimal.h"
#import "SmartDeviceLink.h"
#import "RBSettingsManager.h"
#import "SDLManager.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

@interface RBModuleViewController : RBScrollViewController

/*
 *  Name of the module. Will be shown in list of modules, as well as module's view 
 *  controller.
 *
 *  Required to be Overridden.
 */
+ (NSString*)moduleTitle;

/*
 *  Description of the module. Will be shown in list of modules if provided.
 *
 *  Required to be Overridden.
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
 *  The minimum required OS version for this module. Defaults to 6.0.
 */
+ (NSString*)minimumSupportedVersion;

/*
 *  Subclasses' view controller. Will only construct view controller once.
 */
+ (RBModuleViewController*)viewController;

/*
 *  Proxy given by SDLManager. Logic relating to proxy should be contained with module.
 */
@property (nonatomic, weak) SDLProxy* proxy;

/*
 *  Local reference to SDLManager's singleton.
 */
@property (nonatomic, readonly) SDLManager* SDLManager;

/*
 *  Local reference to RBSettingsManager's singleton.
 */
@property (nonatomic, readonly) RBSettingsManager* settingsManager;

@end
