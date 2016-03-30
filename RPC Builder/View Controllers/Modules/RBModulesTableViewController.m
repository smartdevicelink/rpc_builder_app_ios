//
//  RBModulesTableViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBModulesTableViewController.h"
#import "RBModuleViewController.h"
#import "RBModuleTableViewCell.h"

@interface RBModulesTableViewController ()

@property (nonatomic, strong) NSArray* modules;

@end

@implementation RBModulesTableViewController

- (void)viewDidLoad {
    self.modules = @[
                     NSStringFromClass([RBModuleViewController class])
                     ];
    
    [self.tableView registerClass:[RBModuleTableViewCell class]
           forCellReuseIdentifier:[RBModuleTableViewCell cellIdentifier]];
}

#pragma mark - Data Sources
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modules.count;
}

#pragma mark - Delegates
#pragma mark UITableView
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RBModuleTableViewCell* cell = (RBModuleTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[RBModuleTableViewCell cellIdentifier]];
    
    [cell updateWithObject:self.modules[indexPath.row]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* classString = self.modules[indexPath.row];
    Class moduleClass = NSClassFromString(classString);

    if ([moduleClass isSubclassOfClass:[RBModuleViewController class]]) {
        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Modules"
                                                             bundle:nil];
        RBModuleViewController* moduleViewController = [storyboard instantiateViewControllerWithIdentifier:classString];
        [self.navigationController pushViewController:moduleViewController
                                             animated:YES];
    }
}

@end
