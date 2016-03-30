//
//  RBModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBModuleViewController.h"

static NSMutableDictionary* moduleImages = nil;

@implementation RBModuleViewController

+ (NSString*)moduleTitle {
    return @"New Module";
}

+ (NSString*)moduleDescription {
    return nil;
}

+ (NSString*)moduleImageName {
    return @"RPCs";
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

- (NSString*)title {
    return [[self class] moduleTitle];
}

@end
