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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)updateWithObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        Class moduleClass = NSClassFromString(object);
        
        if ([moduleClass isSubclassOfClass:[RBModuleViewController class]]) {
            self.textLabel.text = [moduleClass moduleTitle];
            if (![[moduleClass minimumSupportedVersion] isEqualToString:[RBModuleViewController minimumSupportedVersion]]) {
                self.detailTextLabel.text = [NSString stringWithFormat:@"Requires iOS %@", [moduleClass minimumSupportedVersion]];
            } else {
                self.detailTextLabel.text = nil;
            }
            self.accessoryType = [moduleClass moduleDescription] ?  UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
            self.imageView.image = [moduleClass moduleImage];
        }
    } else {
        NSLog(@"error");
    }
}

@end
