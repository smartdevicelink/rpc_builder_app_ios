//
//  RBManager.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

#import "SDLConfiguration.h"

@class SDLProxy;

extern NSString* const SDLManagerRegisterAppInterfaceResponseNotification;

extern NSString* const SDLManagerConnectedKeyPath;
extern void* SDLManagerConnectedContext;

@interface SDLManager : NSObject

@property (nonatomic, readonly) SDLProxy* proxy;

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

@property (nonatomic, strong) NSDictionary* registerAppDictionary;

+ (instancetype)sharedManager;

- (BOOL)connectWithConfiguration:(SDLConfiguration*)configuration;
- (void)disconnect;

- (void)sendRequestDictionary:(NSDictionary*)requestDictionary bulkData:(NSData*)bulkData;

- (void)presentSettingsViewController;

@end
