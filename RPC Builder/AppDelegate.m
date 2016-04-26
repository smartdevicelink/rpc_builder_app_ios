//
//  AppDelegate.m
//  RPC Builder
//

#import "AppDelegate.h"
#import "SDLManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

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
        [[SDLManager sharedManager] presentSettingsViewController];
    }
    
    return YES;
}

@end
