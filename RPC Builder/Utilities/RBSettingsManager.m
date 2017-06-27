//
//  RBSettingsManager.m
//  RPC Builder
//

#import "RBSettingsManager.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "RBParser.h"

#import "UIAlertController+Minimal.h"

#import "SmartDeviceLink.h"

NSString* const RBSettingsManagerSpecFileStatusDidChangeNotification = @"RBSettingsManagerSpecFileStatusDidChangeNotification";
NSString* const RBSettingsManagerNotificationErrorKey = @"RBSettingsManagerNotificationErrorKey";

NSString* const RBSettingsManagerRPCsAvailableNotification = @"RBSettingsManagerRPCsAvailableNotification";

NSString* const RBSpecURLStringDefault = @"Mobile_API.xml";
NSString* const RBSpecFileKey = @"specFile";
NSString* const RBSpecFileURLKey = @"specFileURL";

NSString* const RBConnectionTypeKey = @"connectionType";

NSString* const RBTCPConnectionIPAddressKey = @"ipAddress";
NSString* const RBTCPConnectionIPAddressDefault = @"127.0.0.1";

NSString* const RBTCPConnectionPortKey = @"port";
NSString* const RBTCPConnectionPortDefault = @"12345";

NSString* const RBAppNameKey = @"appName";
NSString* const RBAppNameDefault = @"RPC Builder";

NSString* const RBShortAppNameKey = @"shortAppName";
NSString* const RBShortAppNameDefault = @"RB";

NSString* const RBAppIDKey = @"appID";
NSString* const RBAppIDDefault = @"1234567";

NSString* const RBAppTypeKey = @"appType";

NSString* const RBTTSNameKey = @"ttsName";
NSString* const RBTTSNameDefault = @"RPC Builder";

NSString* const RBVRSynonymsKey = @"vrSynonyms";
NSString* const RBVRSynonymsDefault = @"RPC Builder, RB";

NSString* const RBVRLanguageKey = @"vrLanguage";

NSString* const RBHMILanguageKey = @"hmiLanguage";

NSString* const RBProtocolStringKey = @"protocolString";
NSString* const RBProtocolStringDefault = @"default";

NSString* const RBRegisterAppInterfaceKey = @"registerAppInterface";

NSString* const RBAudioStreamingBufferSizeKey = @"audioStreamingBufferSize";
NSString* const RBVideoStreamingBufferSizeKey = @"videoStreamingBufferSize";
NSUInteger const RBStreamingBufferSizeDefault = 131071;

NSString* const RBVideoStreamingMinFrameRateKey = @"videoStreamingMinFrameRate";

NSString* const RBVideoStreamingMaxFrameRateKey = @"videoStreamingMaxFrameRate";

#ifndef SETTER_HELPERS
#define STRING_SETTER(variableName, key)                   \
                                                           \
    if (![variableName isEqualToString:_##variableName]) { \
        _##variableName = variableName;                    \
        [self sdl_setObject:variableName                      \
                  forKey:key];                             \
    }

#define NUMBER_SETTER(variableName, key)                 \
                                                         \
    if (variableName != _##variableName) {               \
        _##variableName = variableName;                  \
        [self sdl_setObject:@(variableName)                 \
                  forKey:key];                           \
    }


#define BOOL_SETTER(variableName, key)   NUMBER_SETTER(variableName, key)


#endif

@interface RBSettingsManager () <RBParserDelegate, RBSpecFileDelegate>

@property (nonatomic, readonly) NSNotificationCenter* notificationCenter;
@property (nonatomic, readonly) NSUserDefaults* userDefaults;

@property (nonatomic, readonly) NSURL* specXMLPath;

@end

@implementation RBSettingsManager {
    BOOL _shouldSynchronize;
}

@synthesize connectionType = _connectionType;
@synthesize appType = _appType;
@synthesize specXMLPath = _specXMLPath;

+ (instancetype)sharedManager {
    static RBSettingsManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[RBSettingsManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        [self.notificationCenter addObserver:self
                                    selector:@selector(applicationWillTerminate:)
                                        name:UIApplicationWillTerminateNotification
                                      object:nil];
        _languages = @[];
        
        _connectionTypes = [RBSDLConfiguration connectionTypeStrings];
        
        _appTypes = [RBSDLConfiguration appTypeStrings];
        
        _shouldSynchronize = NO;
        
        [self sdl_loadSettings];
    }
    return self;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
}

#pragma mark - Notification Observers
- (void)applicationWillTerminate:(UIApplication*)application {
    [self sdl_synchronize];
}

#pragma mark - Getters
- (NSArray*)specXMLs {
    NSMutableArray* fileURLs = [NSMutableArray arrayWithArray:self.bundleSpecXMLs];
    [fileURLs addObjectsFromArray:self.sharedSpecXMLs];
    
    NSMutableArray* files = [NSMutableArray array];
    for (id file in fileURLs) {
        NSURL* fileURL = nil;
        if ([file isKindOfClass:[NSString class]]) {
            fileURL = [NSURL fileURLWithPath:file];
        } else if ([file isKindOfClass:[NSURL class]]) {
            fileURL = file;
        }
        [files addObject:[RBSpecFile fileWithURL:fileURL]];
    }
    
    return files;
}

- (NSArray*)bundleSpecXMLs {
    static NSArray* bundleSpecXMLs = nil;
    if (!bundleSpecXMLs) {
        bundleSpecXMLs = [[NSBundle mainBundle] pathsForResourcesOfType:@"xml"
                                                            inDirectory:nil];
    }
    return bundleSpecXMLs;
}

- (NSArray*)sharedSpecXMLs {
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.specXMLPath
                                                   includingPropertiesForKeys:nil
                                                                      options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles)
                                                                        error:nil];
    return [[files reverseObjectEnumerator] allObjects];
}

- (SDLConnectionType)connectionType {
    if ([self.connectionTypeString isEqualToString:SDLConnectionTypeStringiAP]) {
        return SDLConnectionTypeiAP;
    } else if ([self.connectionTypeString isEqualToString:SDLConnectionTypeStringTCP]) {
        return SDLConnectionTypeTCP;
    } else {
        return SDLConnectionTypeUnknown;
    }
}

- (SDLAppType)appType {
    if ([self.appTypeString isEqualToString:SDLAppTypeStringMedia]) {
        return SDLAppTypeMedia;
    } else if ([self.appTypeString isEqualToString:SDLAppTypeStringNonMedia]) {
        return SDLAppTypeNonMedia;
    } else if ([self.appTypeString isEqualToString:SDLAppTypeStringNavigation]) {
        return SDLAppTypeNavigation;
    } else {
        return SDLAppTypeUnknown;
    }
}

- (SDLLanguage*)vrLanguage {
    return [SDLLanguage valueOf:self.vrLanguageString];
}

- (SDLLanguage*)hmiLanguage {
    return [SDLLanguage valueOf:self.hmiLanguageString];
}

- (NSArray*)vrSynonyms {
    return [[[self.vrSynonymsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@","] copy];
}

#pragma mark - Setters
- (void)setSpecFile:(RBSpecFile *)specFile {
    if (![self.specFile isEqual:specFile]) {
        _specFile = specFile;
        if (specFile.data) {
            [[RBParser sharedParser] parseSpecData:specFile.data
                                          delegate:self];
        }
    }
}

- (void)setConnectionTypeString:(NSString *)connectionTypeString {
    STRING_SETTER(connectionTypeString, RBConnectionTypeKey);
}

- (void)setConnectionType:(SDLConnectionType)connectionType {
    if (connectionType != _connectionType) {
        NSString* connectionTypeString = nil;
        switch (connectionType) {
            case SDLConnectionTypeiAP:
                connectionTypeString = SDLConnectionTypeStringiAP;
                break;
            case SDLConnectionTypeTCP:
                connectionTypeString = SDLConnectionTypeStringTCP;
                break;
            case SDLConnectionTypeUnknown:
            default:
                break;
        }
        
        if (connectionTypeString) {
            self.connectionTypeString = connectionTypeString;
        } else {
            NSAssert(NO, @"Attempting to set protocol type to an unknown value.");
        }
    }
}

- (void)setProtocolString:(NSString *)protocolString {
    STRING_SETTER(protocolString, RBProtocolStringKey);
}

- (void)setIpAddress:(NSString *)ipAddress {
    STRING_SETTER(ipAddress, RBTCPConnectionIPAddressKey);
}

- (void)setPort:(NSString *)port {
    STRING_SETTER(port, RBTCPConnectionPortKey);
}

- (void)setAppName:(NSString *)appName {
    STRING_SETTER(appName, RBAppNameKey);
}

- (void)setShortAppName:(NSString *)shortAppName {
    STRING_SETTER(shortAppName, RBShortAppNameKey);
}

- (void)setAppID:(NSString *)appID {
    STRING_SETTER(appID, RBAppIDKey);
}

- (void)setTtsName:(NSString *)ttsName {
    STRING_SETTER(ttsName, RBTTSNameKey);
}

- (void)setVrSynonymsString:(NSString *)vrSynonymsString {
    STRING_SETTER(vrSynonymsString, RBVRSynonymsKey);
}

- (void)setAppTypeString:(NSString *)appTypeString {
    STRING_SETTER(appTypeString, RBAppTypeKey);
}

- (void)setAppType:(SDLAppType)appType {
    if (appType != _appType) {
        NSString* appTypeString = nil;
        switch (appType) {
            case SDLAppTypeMedia:
                appTypeString = SDLAppTypeStringMedia;
                break;
            case SDLAppTypeNonMedia:
                appTypeString = SDLAppTypeStringNonMedia;
                break;
            case SDLAppTypeNavigation:
                appTypeString = SDLAppTypeStringNavigation;
                break;
            case SDLAppTypeUnknown:
            default:
                break;
        }
        
        if (appTypeString) {
            self.appTypeString = appTypeString;
        } else {
            NSAssert(NO, @"Attempting to set app type to an unknown value.");
        }
    }
}

- (void)setVrLanguageString:(NSString *)vrLanguageString {
    STRING_SETTER(vrLanguageString, RBVRLanguageKey);
}

- (void)setVrLanguage:(SDLLanguage *)vrLanguage {
    self.vrLanguageString = vrLanguage.value;
}

- (void)setHmiLanguageString:(NSString *)hmiLanguageString {
    STRING_SETTER(hmiLanguageString, RBHMILanguageKey);
}

- (void)setHmiLanguage:(SDLLanguage *)hmiLanguage {
    self.hmiLanguageString = hmiLanguage.value;
}

- (void)setRegisterAppInterfaceDictionary:(NSDictionary *)registerAppInterfaceDictionary {
    if (![registerAppInterfaceDictionary isEqualToDictionary:_registerAppInterfaceDictionary]) {
        _registerAppInterfaceDictionary = registerAppInterfaceDictionary;
        [self sdl_setObject:registerAppInterfaceDictionary
                  forKey:RBRegisterAppInterfaceKey];
    }
}

- (void)setAudioStreamingBufferSize:(NSUInteger)audioStreamingBufferSize {
    NUMBER_SETTER(audioStreamingBufferSize, RBAudioStreamingBufferSizeKey);
}

- (void)setVideoStreamingBufferSize:(NSUInteger)videoStreamingBufferSize {
    NUMBER_SETTER(videoStreamingBufferSize, RBVideoStreamingBufferSizeKey);
}

- (void)setVideoStreamingMinimumFrameRate:(CGFloat)videoStreamingMinimumFrameRate {
    NUMBER_SETTER(videoStreamingMinimumFrameRate, RBVideoStreamingMinFrameRateKey);
}

- (void)setVideoStreamingMaximumFrameRate:(CGFloat)videoStreamingMaximumFrameRate {
    NUMBER_SETTER(videoStreamingMaximumFrameRate, RBVideoStreamingMaxFrameRateKey);
}

#pragma mark - Private
#pragma mark Getters
- (NSUserDefaults*)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSNotificationCenter*)notificationCenter {
    return [NSNotificationCenter defaultCenter];
}

- (NSURL*)specXMLPath {
    if (!_specXMLPath) {
        NSString *documentsPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                             NSUserDomainMask,
                                                                             YES) firstObject];
        documentsPathString = [documentsPathString stringByAppendingString:@"/SpecXMLs/"];
        _specXMLPath = [NSURL fileURLWithPath:documentsPathString];
    }
    return _specXMLPath;
}

#pragma mark Helpers
- (void)sdl_synchronize {
    if (_shouldSynchronize) {
        _shouldSynchronize = NO;
        [self.userDefaults synchronize];
    }
}

- (void)sdl_loadSettings {
    // Spec Settings
    NSURL* specURL = [self.userDefaults URLForKey:RBSpecFileURLKey];
    if (!specURL) {
        specURL = [NSURL URLWithString:RBSpecURLStringDefault];
        [self.userDefaults setURL:specURL
                           forKey:RBSpecFileURLKey];
    }
    
    RBSpecFile* specFile = [[RBSpecFile alloc] initWithURL:specURL];
    specFile.delegate = self;
    [specFile fetchUrl];
    
    // Protocol Settings
    _connectionTypeString = [self sdl_stringForKey:RBConnectionTypeKey
                             withDefaultValue:[RBSDLConfiguration defaultConfiguration].connectionTypeString];
    _protocolString = [self sdl_stringForKey:RBProtocolStringKey
                         withDefaultValue:RBProtocolStringDefault];
    _ipAddress = [self sdl_stringForKey:RBTCPConnectionIPAddressKey
                    withDefaultValue:RBTCPConnectionIPAddressDefault];
    _port = [self sdl_stringForKey:RBTCPConnectionPortKey
               withDefaultValue:RBTCPConnectionPortDefault];
    
    // App Settings
    _appName = [self sdl_stringForKey:RBAppNameKey
                  withDefaultValue:RBAppNameDefault];
    _shortAppName = [self sdl_stringForKey:RBShortAppNameKey
                       withDefaultValue:RBShortAppNameDefault];
    _appID = [self sdl_stringForKey:RBAppIDKey
                withDefaultValue:RBAppIDDefault];
    _appTypeString = [self sdl_stringForKey:RBAppTypeKey
                        withDefaultValue:SDLAppTypeStringMedia];
    _ttsName = [self sdl_stringForKey:RBTTSNameKey
                  withDefaultValue:RBTTSNameDefault];
    _vrSynonymsString = [self sdl_stringForKey:RBVRSynonymsKey
                           withDefaultValue:RBVRSynonymsDefault];
    if (self.languages.count) {
        _vrLanguageString = [self sdl_stringForKey:RBVRLanguageKey
                               withDefaultValue:self.languages.firstObject];
        _hmiLanguageString = [self sdl_stringForKey:RBHMILanguageKey
                                withDefaultValue:self.languages.firstObject];
    }

    
    SDLRegisterAppInterface* rai = [SDLRPCRequestFactory buildRegisterAppInterfaceWithAppName:@"Spec App"
                                                                                   isMediaApp:@YES
                                                                              languageDesired:self.hmiLanguage
                                                                                        appID:@"123456"];
    
    // We can repurpose this function in the future to be able to resend RPCs maybe from the Console.
    NSMutableDictionary* raiDictionary = [[rai valueForKey:@"function"] mutableCopy];
    NSDictionary* raiParametersDictionary = raiDictionary[@"parameters"];
    NSMutableDictionary* mutableRaiParametersDictionary = [@{} mutableCopy];
    for (NSString* key in raiParametersDictionary.allKeys) {
        id value = raiParametersDictionary[key];
        if ([value isKindOfClass:[SDLRPCStruct class]]) {
            mutableRaiParametersDictionary[key] = [value valueForKey:@"store"];
        } else {
            mutableRaiParametersDictionary[key] = value;
        }
    }
    raiDictionary[@"parameters"] = mutableRaiParametersDictionary;
    
    _registerAppInterfaceDictionary = [self sdl_dictionaryForKey:RBRegisterAppInterfaceKey
                                             withDefaultValue:raiDictionary];
    
    // Steaming
    _audioStreamingBufferSize = [[self sdl_numberForKey:RBAudioStreamingBufferSizeKey
                                       withDefaultValue:@(RBStreamingBufferSizeDefault)] unsignedIntegerValue];
    _videoStreamingBufferSize = [[self sdl_numberForKey:RBVideoStreamingBufferSizeKey
                                       withDefaultValue:@(RBStreamingBufferSizeDefault)] unsignedIntegerValue];
    
    _videoStreamingMinimumFrameRate = [[self sdl_numberForKey:RBVideoStreamingMinFrameRateKey
                                             withDefaultValue:@(0)] floatValue];
    _videoStreamingMaximumFrameRate = [[self sdl_numberForKey:RBVideoStreamingMaxFrameRateKey
                                             withDefaultValue:@(0)] floatValue];
    if (!_videoStreamingMinimumFrameRate
        || !_videoStreamingMaximumFrameRate) {
        CGFloat minFrameRate = 0;
        CGFloat maxFrameRate = 0;
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
            AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            for (AVFrameRateRange* frameRateRange in [[videoDevice activeFormat] videoSupportedFrameRateRanges]) {
                if (minFrameRate == 0) {
                    minFrameRate = frameRateRange.minFrameRate;
                } else {
                    minFrameRate = MIN(minFrameRate, frameRateRange.minFrameRate);
                }
                maxFrameRate = MAX(maxFrameRate, frameRateRange.maxFrameRate);
            }
        } else {
            // Should only be for pre iPhone 6
            minFrameRate = 1;
            maxFrameRate = 30;
        }
        
        self.videoStreamingMinimumFrameRate = minFrameRate;
        self.videoStreamingMaximumFrameRate = maxFrameRate;
    }
    
    [self sdl_synchronize];
}

- (void)sdl_setObject:(id)object forKey:(NSString*)key {
    [self.userDefaults setObject:object
                          forKey:key];
    _shouldSynchronize = YES;
}

- (NSString*)sdl_stringForKey:(NSString*)key withDefaultValue:(NSString*)defaultValue {
    NSString* stringValue = [self.userDefaults stringForKey:key];
    if (!stringValue) {
        stringValue = defaultValue;
        [self sdl_setObject:stringValue
                  forKey:key];
    }
    return stringValue;
}

- (NSNumber*)sdl_numberForKey:(NSString*)key withDefaultValue:(NSNumber*)defaultValue {
    NSNumber* numberObject = [self.userDefaults objectForKey:key];
    if (!numberObject) {
        numberObject = defaultValue;
        [self sdl_setObject:numberObject
                  forKey:key];
    }
    return numberObject;
}

- (NSDictionary*)sdl_dictionaryForKey:(NSString*)key withDefaultValue:(NSDictionary*)defaultValue {
    NSDictionary* dictObject = [self.userDefaults objectForKey:key];
    if (!dictObject) {
        dictObject = defaultValue;
        [self sdl_setObject:dictObject
                  forKey:key];
    }
    return dictObject;
}

- (BOOL)sdl_boolForKey:(NSString*)key withDefaultValue:(BOOL)defaultValue {
    return [[self sdl_numberForKey:key
               withDefaultValue:@(defaultValue)] boolValue];
}

- (NSArray*)sdl_baseValuesFromElements:(NSArray*)elements {
    NSMutableArray* extractedValues = [NSMutableArray arrayWithCapacity:elements.count];
    for (RBElement* element in elements) {
        [extractedValues addObject:[element name]];
    }
    return [extractedValues copy];
}

- (id)sdl_objectForKey:(NSString*)key withDefaultObject:(id (^)(void))objectCreationBlock {
    id object = [self.userDefaults objectForKey:key];
    if (!object) {
        if (objectCreationBlock) {
            object = objectCreationBlock();
        }
    }
    return object;
}

- (void)sdl_updateSpecFileStatus:(RBSpecFileStatus)status {
    if (_specFileStatus != status) {
        _specFileStatus = status;
        NSDictionary* userInfo = nil;
        NSError* error = [[RBParser sharedParser] error];
        if (error) {
            userInfo = @{
                         RBSettingsManagerNotificationErrorKey : error
                         };
        }
        [self.notificationCenter postNotificationName:RBSettingsManagerSpecFileStatusDidChangeNotification
                                               object:nil
                                             userInfo:userInfo];
    }
}

#pragma mark - Delegates
#pragma mark RBParser
- (void)parserDidFinish:(RBParser *)parser {
    [self.userDefaults setURL:_specFile.url
                       forKey:RBSpecFileURLKey];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:RBNameKey
                                                                   ascending:YES
                                                                    selector:@selector(localizedCaseInsensitiveCompare:)];
    _availableRPCs = [[[RBParser sharedParser] RPCs] sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.languages = [self sdl_baseValuesFromElements:[[[RBParser sharedParser] enumOfType:@"Language"] elements]];
    [self sdl_updateSpecFileStatus:RBSpecFileStatusSuccess];
    [self.notificationCenter postNotificationName:RBSettingsManagerRPCsAvailableNotification
                                           object:_availableRPCs];
}

- (void)parserErrorOccurred:(RBParser *)parser {
    [self sdl_updateSpecFileStatus:RBSpecFileStatusError];
}

#pragma mark RBSpecFile
- (void)specFileFetchUrlDidFinish:(RBSpecFile *)file {
    _specFile = file;
    if (file.data) {
        [[RBParser sharedParser] parseSpecData:file.data
                                      delegate:self];
    }
}

- (void)specFile:(RBSpecFile *)file fetchUrlDidFinishWithError:(NSError *)error {
    _specFile = nil;
    [self sdl_updateSpecFileStatus:RBSpecFileStatusError];
}

@end
