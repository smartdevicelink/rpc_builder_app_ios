//
//  RBManager.m
//  RPC Builder
//

#import "RBSDLManager.h"
#import "SmartDeviceLink.h"

#import "RBSettingsViewController.h"
#import "RBAppRegistrationViewController.h"

NSString* const SDLManagerRegisterAppInterfaceResponseNotification = @"SDLManagerRegisterAppInterfaceResponseNotification";

NSString* const SDLManagerConnectedKeyPath = @"isConnected";
void* SDLManagerConnectedContext = &SDLManagerConnectedContext;

static NSString* const AppIconFileName = @"SDLAppIcon";

static NSString* const SDLRequestKey = @"request";

@interface RBSDLManager () <SDLProxyListener>

@property (nonatomic, strong) RBSDLConfiguration* configuration;

@property (nonatomic) NSUInteger correlationID;
@property (nonatomic, readonly) NSNumber* nextCorrelationID;

@end

@implementation RBSDLManager

+ (instancetype)sharedManager {
    static RBSDLManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RBSDLManager alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Public
- (BOOL)connectWithConfiguration:(RBSDLConfiguration *)configuration {
    if (!configuration) {
        NSLog(@"No specified configuration. Cannot start proxy.");
        return NO;
    }
    if (self.isConnected || _proxy) {
        [self disconnect];
    }
    _configuration = configuration;
    switch (configuration.connectionType) {
        case SDLConnectionTypeiAP:
            _proxy = [SDLProxyFactory buildSDLProxyWithListener:self];
            break;
        case SDLConnectionTypeTCP:
            _proxy = [SDLProxyFactory buildSDLProxyWithListener:self
                                                   tcpIPAddress:configuration.ipAddress
                                                        tcpPort:configuration.port];
            break;
        case SDLConnectionTypeUnknown:
        default:
            NSLog(@"Unknown proxy configuration.");
            return NO;
            break;
    }
    return YES;
}

- (void)disconnect {
    _configuration = nil;
    [self sdl_stopProxy];
}

- (SDLRPCRequest*)requestForDictionary:(NSDictionary *)requestDictionary withBulkData:(NSData *)bulkData {
    return [self requestOfClass:[SDLRPCRequest class]
                  forDictionary:requestDictionary
                   withBulkData:bulkData];
}

- (id)requestOfClass:(Class)classType forDictionary:(NSDictionary*)requestDictionary withBulkData:(NSData*)bulkData {
    NSMutableDictionary* mutableRequestDictionary = [@{SDLRequestKey : requestDictionary} mutableCopy];
    if (![classType isSubclassOfClass:[SDLRPCRequest class]]) {
        NSLog(@"Attempting to convert dictionary for %@ that is not a subclass of %@", NSStringFromClass(classType), NSStringFromClass(SDLRPCRequest.class));
        return nil;
    }
    id request = [[classType alloc] initWithDictionary:mutableRequestDictionary];
    [request setBulkData:bulkData];
    return request;
}

- (void)sendRequestDictionary:(NSDictionary *)requestDictionary bulkData:(NSData *)bulkData {
    [self sendRequest:[self requestForDictionary:requestDictionary
                                    withBulkData:bulkData]];
}

- (NSNumber*)sendRequest:(SDLRPCRequest *)request {
    if (!self.isConnected) {
        return nil;
    }
    request.correlationID = self.nextCorrelationID;
    [_proxy sendRPC:request];
    return request.correlationID;
}

- (void)presentSettingsViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    RBSettingsViewController* settingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"RBSettingsViewController"];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    
    UIViewController* rootViewController = [self sdl_getTopMostViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    if (![rootViewController isKindOfClass:[RBAppRegistrationViewController class]]) {
        // HAX: http://stackoverflow.com/questions/1922517/how-does-performselectorwithobjectafterdelay-work
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [rootViewController presentViewController:navigationController
                                             animated:YES
                                           completion:nil];
        });
    }
}

#pragma mark Getters
- (NSNumber*)nextCorrelationID {
    return @(++_correlationID);
}

#pragma mark - Delegates
#pragma mark SDLProxyListener
- (void)onOnDriverDistraction:(SDLOnDriverDistraction *)notification { }

- (void)onOnHMIStatus:(SDLOnHMIStatus *)notification { }

- (void)onProxyClosed {
    [self sdl_stopProxy];
}

- (void)onProxyOpened {
    [self sdl_updatedIsConnected:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    if (self.registerAppDictionary) {
        [self sendRequestDictionary:self.registerAppDictionary
                           bulkData:nil];
    }
}

- (void)onRegisterAppInterfaceResponse:(SDLRegisterAppInterfaceResponse *)response {
    if (![response.success boolValue]) {
        [self disconnect];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SDLManagerRegisterAppInterfaceResponseNotification
                                                        object:response];
}

#pragma mark - Private
- (void)sdl_stopProxy {
    [self sdl_updatedIsConnected:NO];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [_proxy dispose];
    _proxy = nil;
}

- (void)sdl_updatedIsConnected:(BOOL)connected {
    [self willChangeValueForKey:@"isConnected"];
    _connected = connected;
    [self didChangeValueForKey:@"isConnected"];
    
    if (![[RBSDLManager sharedManager] isConnected]) {
        [self presentSettingsViewController];
    }
}

- (UIViewController*)sdl_getTopMostViewController:(UIViewController*)viewController {
    if ([viewController presentedViewController]) {
        return [self sdl_getTopMostViewController:[viewController presentedViewController]];
    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [[(UINavigationController*)viewController viewControllers] lastObject];
    } else {
        return viewController;
    }
}

@end
