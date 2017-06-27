//
//  RBConfiguration.h
//  RPC Builder
//

#import <Foundation/Foundation.h>

extern NSString* const SDLConnectionTypeStringiAP;
extern NSString* const SDLConnectionTypeStringTCP;

extern NSString* const SDLAppTypeStringMedia;
extern NSString* const SDLAppTypeStringNonMedia;
extern NSString* const SDLAppTypeStringNavigation;

typedef NS_ENUM(NSUInteger, SDLConnectionType) {
    SDLConnectionTypeiAP,
    SDLConnectionTypeTCP,
    SDLConnectionTypeUnknown
};

typedef NS_ENUM(NSUInteger, SDLAppType) {
    SDLAppTypeMedia = 0,
    SDLAppTypeNonMedia,
    SDLAppTypeNavigation,
    SDLAppTypeUnknown
};

@interface RBSDLConfiguration : NSObject

/*
 *  Returns all available connection type's respective string values.
 */
+ (NSArray*)connectionTypeStrings;

/*
 *  Returns all available app type's respective string values.
 */
+ (NSArray*)appTypeStrings;

/*
 *  Default configuration. Uses a connectionType of iAP.
 */
+ (instancetype)defaultConfiguration;

/*
 *  Uses a connectionType of TCPSpecified with using specified ip address and port.
 */
+ (instancetype)tcpConfiguration:(NSString*)ipAddress port:(NSString*)port;

@property (nonatomic, readonly) SDLConnectionType connectionType;
@property (nonatomic, readonly) NSString* connectionTypeString;
@property (nonatomic, readonly) NSString* ipAddress;
@property (nonatomic, readonly) NSString* port;


@end
