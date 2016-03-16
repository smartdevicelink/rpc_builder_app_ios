//
//  RBConsoleViewController.m
//  RPC Builder
//

#import "RBConsoleViewController.h"

#import "UIAlertController+Minimal.h"

#import "RBLogInfo.h"

#import "RBLogInfoTableViewCell.h"

@interface RBConsoleViewController () <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) UIAlertController* alertController;

@property (nonatomic, strong) NSMutableArray* messagesArray;

@end

@implementation RBConsoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _alertController = [UIAlertController simpleAlertWithTitle:nil
                                                       message:nil];
        
    _messagesArray = [NSMutableArray arrayWithCapacity:100];
    
    [_tableView registerClass:[RBLogInfoTableViewCell class]
       forCellReuseIdentifier:[RBLogInfoTableViewCell cellIdentifier]];
    
    [SDLDebugTool addConsole:self];
    
}

- (void)logInfo:(NSString *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_messagesArray addObject:[RBLogInfo logInfoWithString:info]];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_messagesArray.count - 1
                                                    inSection:0];
        UITableViewRowAnimation rowAnimation = UITableViewRowAnimationNone;
        BOOL animated = NO;
        if (self.tabBarController.selectedViewController == self) {
            rowAnimation = UITableViewRowAnimationAutomatic;
            animated = YES;
        }
        
        [_tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:rowAnimation];
        [_tableView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:animated];
    });
}

#pragma mark - Getters


#pragma mark - Delegates
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RBLogInfo* logInfo = _messagesArray[indexPath.row];
    [_alertController setTitle:logInfo.title];
    [_alertController setMessage:logInfo.message];
    [self presentViewController:_alertController
                       animated:YES
                     completion:^{
                         [tableView deselectRowAtIndexPath:indexPath
                                                  animated:YES];
                     }];
}

#pragma mark - Data Source
#pragma mark UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messagesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RBLogInfoTableViewCell* cell = (RBLogInfoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[RBLogInfoTableViewCell cellIdentifier]];
    
    RBLogInfo* logInfo = _messagesArray[indexPath.row];
    
    [cell updateWithObject:logInfo];
    
    return cell;
}


@end
