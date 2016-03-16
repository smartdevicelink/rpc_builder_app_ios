//
//  AppDelegate.m
//  RPC Builder
//

#import "AppDelegate.h"
#import "SDLManager.h"

#import "RBSettingsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)self.window.rootViewController;
        for (UIViewController* viewController in tabBarController.viewControllers) {
            if ([viewController isKindOfClass:[UINavigationController class]]) {
                UINavigationController* navigationController = (UINavigationController*)viewController;
                for (UIViewController* childViewController in navigationController.viewControllers) {
                    [childViewController view];
                }
            }
        }
    }
    
    [self.window makeKeyAndVisible];
    
    if (![[SDLManager sharedManager] isConnected]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle:nil];
        RBSettingsViewController* settingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"RBSettingsViewController"];
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];

        // HAX: http://stackoverflow.com/questions/1922517/how-does-performselectorwithobjectafterdelay-work
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.window.rootViewController presentViewController:navigationController
                                                         animated:YES
                                                       completion:nil];
        });
    }
    
    return YES;
}

@end
