//
//  RBConfiguration.m
//  RPC Builder
//

#import "RBSDLConfiguration.h"

NSString* const SDLConnectionTypeStringiAP = @"iAP";
NSString* const SDLConnectionTypeStringTCP = @"TCP";

NSString* const SDLAppTypeStringMedia = @"Media";
NSString* const SDLAppTypeStringNonMedia = @"Non-Media";
NSString* const SDLAppTypeStringNavigation = @"Navigation";

@implementation RBSDLConfiguration

- (instancetype)init {
    if (self = [super init]) {
        _connectionType = SDLConnectionTypeiAP;
        _ipAddress = nil;
        _port = nil;
    }
    return self;
}

#pragma mark - Class Constructors
+ (instancetype)defaultConfiguration {
    return [[RBSDLConfiguration alloc] init];
}

+ (instancetype)tcpConfiguration:(NSString *)ipAddress port:(NSString *)port {
    RBSDLConfiguration* config = [self defaultConfiguration];
    config->_connectionType = SDLConnectionTypeTCP;
    config->_ipAddress = ipAddress;
    config->_port = port;
    return config;
}

#pragma mark - Getters
+ (NSArray*)appTypeStrings {
    static NSArray* appTypeStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!appTypeStrings) {
            appTypeStrings = @[SDLAppTypeStringMedia,
                               SDLAppTypeStringNonMedia,
                               SDLAppTypeStringNavigation
                               ];
        }
    });
    return appTypeStrings;
}

- (NSString*)connectionTypeString {
    switch (self.connectionType) {
        case SDLConnectionTypeiAP:
            return SDLConnectionTypeStringiAP;
            break;
        case SDLConnectionTypeTCP:
            return SDLConnectionTypeStringTCP;
            break;
        default:
            return nil;
            break;
    }
}

+ (NSArray*)connectionTypeStrings {
    static NSArray* connectionTypeStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!connectionTypeStrings) {
            connectionTypeStrings = @[SDLConnectionTypeStringiAP,
                                      SDLConnectionTypeStringTCP];
        }
    });
    return connectionTypeStrings;
}

@end
