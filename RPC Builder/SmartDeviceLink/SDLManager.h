//
//  RBManager.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

#import "SDLConfiguration.h"

@class SDLProxy;
@class SDLRPCRequest;

extern NSString* const SDLManagerRegisterAppInterfaceResponseNotification;

extern NSString* const SDLManagerConnectedKeyPath;
extern void* SDLManagerConnectedContext;

@interface SDLManager : NSObject

@property (nonatomic, readonly) SDLProxy* proxy;

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

@property (nonatomic, strong) NSDictionary* registerAppDictionary;

+ (instancetype)sharedManager;

// Creates generic SDLRPCRequest for a given dictionary.
- (SDLRPCRequest*)requestForDictionary:(NSDictionary*)requestDictionary withBulkData:(NSData*)bulkData;

// Creates a specific SDLRPCRequest subtype for a given dictionary.
- (id)requestOfClass:(Class)classType forDictionary:(NSDictionary*)requestDictionary withBulkData:(NSData*)bulkData;

- (BOOL)connectWithConfiguration:(SDLConfiguration*)configuration;
- (void)disconnect;

- (void)sendRequestDictionary:(NSDictionary*)requestDictionary bulkData:(NSData*)bulkData;

- (void)presentSettingsViewController;

@end
