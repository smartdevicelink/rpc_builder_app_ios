//
//  RBManager.m
//  RPC Builder
//

#import "SDLManager.h"
#import "SmartDeviceLink.h"

NSString* const SDLManagerRegisterAppInterfaceResponseNotification = @"SDLManagerRegisterAppInterfaceResponseNotification";

static NSString* const AppIconFileName = @"SDLAppIcon";

static NSString* const SDLRequestKey = @"request";

@interface SDLManager () <SDLProxyListener>

@property (nonatomic, strong) SDLConfiguration* configuration;

@property (nonatomic) NSUInteger correlationID;
@property (nonatomic, readonly) NSNumber* nextCorrelationID;

@end

@implementation SDLManager

+ (instancetype)sharedManager {
    static SDLManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[SDLManager alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Public
- (BOOL)connectWithConfiguration:(SDLConfiguration *)configuration {
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


- (void)sendRequestDictionary:(NSDictionary *)requestDictionary bulkData:(NSData *)bulkData {
    NSMutableDictionary* mutableRequestDictionary = [@{SDLRequestKey : requestDictionary} mutableCopy];
    SDLRPCRequest* request = [[SDLRPCRequest alloc] initWithDictionary:mutableRequestDictionary];
    request.bulkData = bulkData;
    [self sdl_sendRequest:request];
}

#pragma mark Getters
- (NSNumber*)nextCorrelationID {
    return @(++_correlationID);
}

- (BOOL)isConnected {
    return [[_proxy valueForKey:@"_isConnected"] boolValue];
}

#pragma mark - Delegates
#pragma mark SDLProxyListener
- (void)onOnDriverDistraction:(SDLOnDriverDistraction *)notification { }

- (void)onOnHMIStatus:(SDLOnHMIStatus *)notification { }

- (void)onProxyClosed {
    [self sdl_stopProxy];
    [self connectWithConfiguration:_configuration];
}

- (void)onProxyOpened {
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
- (NSNumber*)sdl_sendRequest:(SDLRPCRequest*)request {
    if (!self.isConnected) {
        return nil;
    }
    request.correlationID = self.nextCorrelationID;
    [_proxy sendRPC:request];
    return request.correlationID;
}

- (void)sdl_stopProxy {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [_proxy dispose];
    _proxy = nil;
}

@end
