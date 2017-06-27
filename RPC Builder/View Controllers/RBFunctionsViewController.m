//
//  RBFunctionsViewController.m
//  RPC Builder
//

#import "RBFunctionsViewController.h"

#import "UIAlertController+Minimal.h"

#import "RBSDLManager.h"

@interface RBFunctionsViewController ()

@property (strong) NSArray* RPCs;

@end

@implementation RBFunctionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"RequestTableViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsManagerRPCsAvailable:)
                                                 name:RBSettingsManagerRPCsAvailableNotification
                                               object:nil];
}

- (IBAction)presentSettingsAction:(id)sender {
    UIAlertController* alertController = [UIAlertController actionSheetWithTitle:nil
                                                                         message:nil];
    
    [alertController addDestructiveActionWithTitle:@"Stop Proxy" handler:^(UIAlertAction *action) {
        [[RBSDLManager sharedManager] disconnect];
    }];
    
    [alertController addCancelAction];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

#pragma mark - Notifications
#pragma mark RBSettingsManager
- (void)settingsManagerRPCsAvailable:(NSNotification*)notification {
    self.RPCs = [[RBSettingsManager sharedManager] availableRPCs];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.RPCs.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RequestTableViewCell"];
    RBFunction* function = self.RPCs[indexPath.row];
    cell.textLabel.text = function.name;
    cell.imageView.image = function.image;
    cell.accessoryType = function.objectDescription ? UITableViewCellAccessoryDetailButton : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    RBFunction* function = self.RPCs[indexPath.row];
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:function.name
                                                                             message:function.objectDescription
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RBFunction* function = self.RPCs[indexPath.row];

    [self.navigationController pushViewController:[self.class viewControllerForFunction:function]
                                         animated:YES];
}


#pragma mark - Private
#pragma mark Getters
+ (NSMutableDictionary*)functionStore {
    static NSMutableDictionary* functionStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        functionStore = [NSMutableDictionary dictionary];
    });
    return functionStore;
}

#pragma mark Functions
+ (RBFunctionViewController*)viewControllerForFunction:(RBFunction*)function {
    RBFunctionViewController* viewController = self.functionStore[function.name];
    if (!viewController) {
        viewController = [[RBFunctionViewController alloc] initWithNibName:@"RBBaseViewController"
                                                                    bundle:nil];
        viewController.function = function;
        self.functionStore[function.name] = viewController;
    }
    return viewController;
}

@end
