//
//  RBManager.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

#import "SDLConfiguration.h"

extern NSString* const SDLManagerRegisterAppInterfaceResponseNotification;

@interface SDLManager : NSObject

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

@property (nonatomic, strong) NSDictionary* registerAppDictionary;

+ (instancetype)sharedManager;

- (BOOL)connectWithConfiguration:(SDLConfiguration*)configuration;
- (void)disconnect;

- (void)sendRequestDictionary:(NSDictionary*)requestDictionary bulkData:(NSData*)bulkData;

@end
