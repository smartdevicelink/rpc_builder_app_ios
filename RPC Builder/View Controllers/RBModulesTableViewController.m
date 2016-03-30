//
//  RBModulesTableViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBModulesTableViewController.h"
#import "RBStreamingModuleViewController.h"
#import "RBModuleTableViewCell.h"
#import "UIAlertController+Minimal.h"

@interface RBModulesTableViewController ()

@property (nonatomic, strong) NSArray* modules;

@end

@implementation RBModulesTableViewController

- (void)viewDidLoad {
    self.modules = @[
                     NSStringFromClass([RBStreamingModuleViewController class])
                     ];
    
    [self.tableView registerClass:[RBModuleTableViewCell class]
           forCellReuseIdentifier:[RBModuleTableViewCell cellIdentifier]];
}

#pragma mark - Data Sources
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modules.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RBModuleTableViewCell* cell = (RBModuleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[RBModuleTableViewCell cellIdentifier]];
    
    [cell updateWithObject:self.modules[indexPath.row]];
    
    return cell;
}

#pragma mark - Delegates
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* classString = self.modules[indexPath.row];
    Class moduleClass = NSClassFromString(classString);

    if ([moduleClass isSubclassOfClass:[RBModuleViewController class]]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Modules"
                                                             bundle:nil];
        UIViewController* viewController = [storyboard instantiateViewControllerWithIdentifier:classString];
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString* classString = self.modules[indexPath.row];
    Class moduleClass = NSClassFromString(classString);
    
    if ([moduleClass isSubclassOfClass:[RBModuleViewController class]]) {
        NSString* moduleDescription = [moduleClass description];
        if (moduleDescription) {
            UIAlertController* alertController = [UIAlertController simpleAlertWithTitle:@"Module Description"
                                                                                 message:[moduleClass moduleDescription]];
            [self presentViewController:alertController
                               animated:YES
                             completion:nil];
        }
    }
}

@end
