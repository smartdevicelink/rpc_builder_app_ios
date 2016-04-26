//
//  RBModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBModuleViewController.h"

#import "RBStreamingModuleViewController.h"
#import "RBAudioPassThruModuleViewController.h"

static NSMutableDictionary* moduleImages = nil;
static NSArray* moduleClassNames = nil;
static NSMutableDictionary* moduleViewControllers = nil;
static UIStoryboard* moduleStoryboard = nil;

@implementation RBModuleViewController

+ (NSString*)moduleTitle {
    return @"New Module";
}

+ (NSString*)moduleDescription {
    return nil;
}

+ (NSString*)moduleImageName {
    return nil;
}

+ (UIImage*)moduleImage {
    if (!self.moduleImageName) {
        return nil;
    }
    if (!moduleImages) {
        moduleImages = [NSMutableDictionary dictionary];
    }
    UIImage* moduleImage = moduleImages[self.moduleImageName];
    if (!moduleImage) {
        moduleImage = [UIImage imageNamed:self.moduleImageName];
        moduleImages[self.moduleImageName] = moduleImage;
    }
    return moduleImage;
}

+ (NSArray*)moduleClassNames {
    if (!moduleClassNames) {
        moduleClassNames = @[
                             [RBStreamingModuleViewController classString], // Streaming
                             [RBAudioPassThruModuleViewController classString]  // Audio Passthru
                             ];
    }
    return moduleClassNames;
}

+ (NSString*)minimumSupportedVersion {
    return @"6.0";
}

+ (NSString*)classString {
    return NSStringFromClass(self.class);
}

+ (RBModuleViewController*)viewController {
    if (!moduleViewControllers) {
        moduleViewControllers = [NSMutableDictionary dictionary];
    }
    NSString* classString = NSStringFromClass(self.class);
    RBModuleViewController* viewController = moduleViewControllers[classString];
    if (!viewController) {
        if (!moduleStoryboard) {
            moduleStoryboard = [UIStoryboard storyboardWithName:@"Modules"
                                                         bundle:nil];
        }
        @try {
            viewController = [moduleStoryboard instantiateViewControllerWithIdentifier:classString];
            moduleViewControllers[classString] = viewController;
        } @catch (NSException *exception) {
            NSAssert(NO, @"Modules Storyboard does not contain a UIViewController with identifier %@", classString);
        }
    }
    
    return viewController;
}

- (NSString*)title {
    return [[self class] moduleTitle];
}

- (RBSettingsManager*)settingsManager {
    return [RBSettingsManager sharedManager];
}

- (SDLManager*)SDLManager {
    return [SDLManager sharedManager];
}

#pragma mark - Overrides
- (CGFloat)scrollViewBottomOffset {
    return CGRectGetHeight(self.tabBarController.tabBar.bounds);
}

@end
