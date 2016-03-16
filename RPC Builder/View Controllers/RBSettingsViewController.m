//
//  RBSettingsViewController.m
//  RPC Builder
//

#import "RBSettingsViewController.h"
#import "RBAppRegistrationViewController.h"
#import "RBSpecFilesViewController.h"

#import "RBParser.h"

#import "RBElementTextField.h"
#import "UIView+Util.h"

#import "RBSpecFile.h"

typedef NS_ENUM(NSUInteger, RBURLStatus) {
    RBURLStatusLoading,
    RBURLStatusError,
    RBURLStatusSuccess
};

@interface RBSettingsViewController () <UITextFieldDelegate, RBSpecFilesViewControllerDelegate>

@property (nonatomic, readonly) UIBarButtonItem* cancelBarButton;
@property (nonatomic, readonly) UIBarButtonItem* nextBarButton;

@property (nonatomic, weak) IBOutlet UILabel* specFileLabel;
@property (nonatomic, weak) IBOutlet RBElementTextField* connectionTypeTextField;

@property (nonatomic, weak) IBOutlet UIView* tcpContainerView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint* tcpContainerHeight;
@property (nonatomic, strong) NSLayoutConstraint* originalTCPContainerHeight;
@property (nonatomic, weak) IBOutlet UITextField* ipAddressTextField;
@property (nonatomic, weak) IBOutlet UITextField* portTextField;

@end

@implementation RBSettingsViewController

@synthesize cancelBarButton = _cancelBarButton;
@synthesize nextBarButton = _nextBarButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(settingsManagerSpecFileStatusDidChange:)
                                    name:RBSettingsManagerSpecFileStatusDidChangeNotification
                                  object:nil];
    
    self.navigationItem.rightBarButtonItem = self.nextBarButton;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if (self.settingsManager.specFile) {
        _specFileLabel.text = self.settingsManager.specFile.fileName;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds),
                                             CGRectGetMaxY(_tcpContainerView.frame));
    
    _connectionTypeTextField.elements = self.settingsManager.connectionTypes;
    _connectionTypeTextField.currentElement = self.settingsManager.connectionTypeString;
    _connectionTypeTextField.inputView = self.pickerView;
    _connectionTypeTextField.inputAccessoryView = self.doneToolbar;
    _connectionTypeTextField.text = self.settingsManager.connectionTypeString;
    
    [self sdl_updateTCPConnectionView];

    _ipAddressTextField.text = self.settingsManager.ipAddress;
    _portTextField.text = self.settingsManager.port;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:NSStringFromClass([RBSpecFilesViewController class])]) {
        RBSpecFilesViewController* viewController = (RBSpecFilesViewController*)segue.destinationViewController;
        viewController.delegate = self;
    }
}

#pragma mark - Actions
- (void)startAction:(id)sender {
    SDLConfiguration* configuration = nil;
    if ([_connectionTypeTextField.text isEqualToString:SDLConnectionTypeStringiAP]) {
        configuration = [SDLConfiguration defaultConfiguration];
    } else if ([_connectionTypeTextField.text isEqualToString:SDLConnectionTypeStringTCP]) {
        configuration = [SDLConfiguration tcpConfiguration:_ipAddressTextField.text
                                                      port:_portTextField.text];
    }

    [self sdl_saveSettings];

    RBAppRegistrationViewController* viewController = [[RBAppRegistrationViewController alloc] initWithNibName:@"RBBaseViewController" bundle:nil];
    viewController.sdlConfiguration = configuration;
    viewController.function = [[RBParser sharedParser] functionOfType:@"RegisterAppInterface"];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Delegates
#pragma mark UITextField
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _connectionTypeTextField) {
        [self sdl_updateTCPConnectionView];
    }
}

#pragma mark - RBSpecFilesViewControllerDelegate
- (void)specFilesViewController:(RBSpecFilesViewController *)viewController didSelectSpecFile:(RBSpecFile *)specFile {
    [viewController.navigationController popViewControllerAnimated:YES];
    self.settingsManager.specFile = specFile;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    _specFileLabel.text = [[[RBSettingsManager sharedManager] specFile] fileName];

}

#pragma mark - Getters
- (UIBarButtonItem*)nextBarButton {
    if (!_nextBarButton) {
        _nextBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(startAction:)];
    }
    return _nextBarButton;
}

#pragma mark - Notifications
#pragma mark RBSettingsManager
- (void)settingsManagerSpecFileStatusDidChange:(NSNotification*)notification {
    NSError* error = notification.userInfo[RBSettingsManagerNotificationErrorKey];
    NSString* newErrorLabel = nil;
    BOOL connectButtonEnabled = YES;
    if (error) {
        connectButtonEnabled = NO;
        newErrorLabel = error.localizedDescription;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[RBSettingsManager sharedManager] specFile]) {
                self.navigationItem.rightBarButtonItem.enabled = YES;
                _specFileLabel.text = [[[RBSettingsManager sharedManager] specFile] fileName];
            }
        });
    }
}

#pragma mark - Private Helpers
- (void)sdl_saveSettings {
    self.settingsManager.connectionTypeString = _connectionTypeTextField.text;
    self.settingsManager.ipAddress = _ipAddressTextField.text;
    self.settingsManager.port = _portTextField.text;
}

- (void)sdl_updateTCPConnectionView {
    if (!_originalTCPContainerHeight) {
        _originalTCPContainerHeight = [_tcpContainerHeight copy];
    }
    if ([_connectionTypeTextField.text isEqualToString:SDLConnectionTypeStringiAP]) {
        _tcpContainerHeight.constant = 0;
    } else {
        _tcpContainerHeight.constant = _originalTCPContainerHeight.constant;
    }
}

@end
