//
//  RBModuleTableViewCell.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBModuleTableViewCell.h"
#import "RBModuleViewController.h"

@implementation RBModuleTableViewCell

- (void)updateWithObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        Class moduleClass = NSClassFromString(object);
        
        if ([moduleClass isSubclassOfClass:[RBModuleViewController class]]) {
            self.textLabel.text = [moduleClass title];
        }
    } else {
        NSLog(@"error");
    }
}

@end
