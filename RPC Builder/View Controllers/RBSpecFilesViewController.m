//
//  RBSpecFilesViewController.m
//  RPC Builder
//

#import "RBSpecFilesViewController.h"

#import "UIAlertController+Minimal.h"

#import "RBSettingsManager.h"

@interface RBSpecFilesViewController () <UITableViewDataSource, UITableViewDelegate, RBSpecFileDelegate>

@property (nonatomic, weak) NSIndexPath* selectedIndex;

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UITextField* specURLTextField;
@property (nonatomic, strong, readonly) UIBarButtonItem* addBarButton;

@property (nonatomic, strong) NSArray* specXMLs;

@property (nonatomic, readonly) RBSpecFile* currentSpecFile;

@property (nonatomic, getter=isCreatingNewSpec) BOOL creatingNewSpec;

@end

@implementation RBSpecFilesViewController

@synthesize addBarButton = _addBarButton;
@synthesize creatingNewSpec = _creatingNewSpec;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _specURLTextField.text = @"https://raw.githubusercontent.com/smartdevicelink/rpc_spec/master/spec.xml";
    
    _specXMLs = [[RBSettingsManager sharedManager] specXMLs];
}

#pragma mark - Actions
- (IBAction)addAction:(id)selector {
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(cancelAction:)];
    UIBarButtonItem* saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                       target:self
                                                                                       action:@selector(saveAction:)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [_specURLTextField becomeFirstResponder];
    }];
}

- (void)cancelAction:(id)selector {
    [_specURLTextField resignFirstResponder];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.addBarButton;
    
    _creatingNewSpec = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (void)saveAction:(id)selector {
    [_specURLTextField resignFirstResponder];
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    _creatingNewSpec = YES;
    
    RBSpecFile* specFile = [[RBSpecFile alloc] initWithURL:[NSURL URLWithString:_specURLTextField.text]];
    specFile.delegate = self;
    [specFile fetchUrl];
}

#pragma mark - Data Source
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _specXMLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RBSpecFileTableViewCell"];
    
    RBSpecFile* file = _specXMLs[indexPath.row];
    
    cell.textLabel.text = file.fileName;
    
    cell.accessoryType = [file isEqual:self.currentSpecFile] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Delegates
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RBSpecFile* file = _specXMLs[indexPath.row];
    
    if (!file.data) {
        file.delegate = self;
        [file fetchUrl];
    } else {
        if ([self.delegate respondsToSelector:@selector(specFilesViewController:didSelectSpecFile:)]) {
            [self.delegate specFilesViewController:self
                                 didSelectSpecFile:_specXMLs[indexPath.row]];
        }
    }
}

#pragma mark RBSpecFile
- (void)specFile:(RBSpecFile *)file fetchUrlDidFinishWithError:(NSError *)error {
    UIAlertController* alertController = [UIAlertController simpleAlertWithTitle:@"Error"
                                                                         message:error.localizedDescription];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    });
}

- (void)specFileFetchUrlDidFinish:(RBSpecFile *)file {
    if (self.isCreatingNewSpec) {
        _creatingNewSpec = NO;
        _specXMLs = [[RBSettingsManager sharedManager] specXMLs];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_specXMLs.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = self.addBarButton;
            
            [UIView animateWithDuration:0.3 animations:^{
                _tableView.alpha = 1.0f;
            } completion:^(BOOL finished) {
                _specURLTextField.text = nil;
            }];
        });
    } else {
        if ([self.delegate respondsToSelector:@selector(specFilesViewController:didSelectSpecFile:)]) {
            [self.delegate specFilesViewController:self
                                 didSelectSpecFile:file];
        }
    }
}

#pragma mark - Private
#pragma mark Getters
- (UIBarButtonItem*)addBarButton {
    if (!_addBarButton) {
        _addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(addAction:)];
    }
    return _addBarButton;
}

- (RBSpecFile*)currentSpecFile {
    return [[RBSettingsManager sharedManager] specFile];
}

@end
