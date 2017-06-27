//
//  RBManager.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

#import "RBSDLConfiguration.h"

@class SDLProxy;
@class SDLRPCRequest;

extern NSString* const SDLManagerRegisterAppInterfaceResponseNotification;

extern NSString* const SDLManagerConnectedKeyPath;
extern void* SDLManagerConnectedContext;

@interface RBSDLManager : NSObject

@property (nonatomic, readonly) SDLProxy* proxy;

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

@property (nonatomic, strong) NSDictionary* registerAppDictionary;

+ (instancetype)sharedManager;

// Creates generic SDLRPCRequest for a given dictionary.
- (SDLRPCRequest*)requestForDictionary:(NSDictionary*)requestDictionary withBulkData:(NSData*)bulkData;

// Creates a specific SDLRPCRequest subtype for a given dictionary.
- (id)requestOfClass:(Class)classType forDictionary:(NSDictionary*)requestDictionary withBulkData:(NSData*)bulkData;

- (BOOL)connectWithConfiguration:(RBSDLConfiguration*)configuration;
- (void)disconnect;

- (void)sendRequestDictionary:(NSDictionary*)requestDictionary bulkData:(NSData*)bulkData;

- (NSNumber*)sendRequest:(SDLRPCRequest*)request;

- (void)presentSettingsViewController;

@end
