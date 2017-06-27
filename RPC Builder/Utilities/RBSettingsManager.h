//
//  RBSettingsManager.h
//  RPC Builder
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RBSDLConfiguration.h"
#import "RBSpecFile.h"

extern NSString* const RBSettingsManagerSpecFileStatusDidChangeNotification;
extern NSString* const RBSettingsManagerNotificationErrorKey;

extern NSString* const RBSettingsManagerRPCsAvailableNotification;

@class SDLLanguage;

typedef NS_ENUM(NSUInteger, RBSpecFileStatus) {
    RBSpecFileStatusNone,
    RBSpecFileStatusError,
    RBSpecFileStatusSuccess,
};

@interface RBSettingsManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) RBSpecFileStatus specFileStatus;
@property (nonatomic, readonly) NSArray* specXMLs;
@property (nonatomic, strong) RBSpecFile* specFile;
@property (nonatomic, strong) NSString* connectionTypeString;
@property (nonatomic, assign) SDLConnectionType connectionType;
@property (nonatomic, readonly) NSArray* connectionTypes;
@property (nonatomic, strong) NSString* protocolString;
@property (nonatomic, strong) NSString* ipAddress;
@property (nonatomic, strong) NSString* port;
@property (nonatomic, strong) NSString* appName;
@property (nonatomic, strong) NSString* shortAppName;
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, strong) NSString* ttsName;
@property (nonatomic, strong) NSString* ttsTypeString;
@property (nonatomic, strong) NSString* vrSynonymsString;
@property (nonatomic, strong) NSString* appTypeString;
@property (nonatomic, assign) SDLAppType appType;
@property (nonatomic, readonly) NSArray* appTypes;
@property (nonatomic, strong) NSString* vrLanguageString;
@property (nonatomic, strong) NSString* hmiLanguageString;
@property (nonatomic, strong) NSArray* languages;

@property (nonatomic, strong) NSDictionary* registerAppInterfaceDictionary;

@property (nonatomic, strong) SDLLanguage* hmiLanguage;
@property (nonatomic, strong) SDLLanguage* vrLanguage;

@property (nonatomic, readonly) NSArray* availableRPCs;

// Streaming Module Settings
@property (nonatomic) NSUInteger audioStreamingBufferSize;
@property (nonatomic) NSUInteger videoStreamingBufferSize;
@property (nonatomic) CGFloat videoStreamingMinimumFrameRate;
@property (nonatomic) CGFloat videoStreamingMaximumFrameRate;

@end
