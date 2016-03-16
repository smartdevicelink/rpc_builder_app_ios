//
//  RBAppRegistrationViewController.m
//  RPC Builder
//

#import "RBAppRegistrationViewController.h"

#import "SmartDeviceLink.h"

#import "UIAlertController+Minimal.h"

@interface RBAppRegistrationViewController ()

@property (nonatomic, strong, readonly) UIAlertController* raiAlertController;

@end

@implementation RBAppRegistrationViewController

@synthesize raiAlertController = _raiAlertController;

- (void)viewDidLoad {
    
    NSDictionary* dict = [self.settingsManager registerAppInterfaceDictionary];
    self.requestDictionary = [dict mutableCopy];
    
    [super viewDidLoad];
    
    [self.notificationCenter addObserver:self
                                selector:@selector(registerAppInterfaceResponse:)
                                    name:SDLManagerRegisterAppInterfaceResponseNotification
                                  object:nil];
}

#pragma mark - Actions
- (void)sendAction:(id)selector {
    [self updateRequestsDictionaryFromSubviews];
    
    self.settingsManager.registerAppInterfaceDictionary = self.requestDictionary;
    
    self.sdlManager.registerAppDictionary = self.requestDictionary;
    [self.sdlManager connectWithConfiguration:_sdlConfiguration];
    
    [self presentViewController:self.raiAlertController
                       animated:YES
                     completion:nil];
}

#pragma mark - Notifications
- (void)registerAppInterfaceResponse:(NSNotification*)notification {
    SDLRegisterAppInterfaceResponse* response = [notification object];
    if ([response.success boolValue]) {
        self.view.userInteractionEnabled = NO;
        void(^dismissBlock)(void) = ^ {
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        };
        if (self.presentedViewController == self.raiAlertController) {
            [self.raiAlertController dismissViewControllerAnimated:YES
                                                        completion:dismissBlock];
        } else {
            dismissBlock();
        }
        self.view.userInteractionEnabled = YES;
    } else {
        NSLog(@"Failed to send RAI");
    }
}

#pragma mark - Private
#pragma mark Getters
- (UIAlertController*)raiAlertController {
    if (!_raiAlertController) {
        _raiAlertController = [UIAlertController alertWithTitle:@"Connecting…"
                                                        message:@"Waiting for Register App Interface Response from SDL Core."
                                                         action:nil];
        __typeof__(self) weakSelf = self;
        [_raiAlertController addDefaultActionWithTitle:@"Cancel" handler:^(UIAlertAction *action) {
            __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf.sdlManager disconnect];
        }];
    }
    return _raiAlertController;
}

@end
