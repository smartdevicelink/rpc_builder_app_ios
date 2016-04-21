//
//  RBAudioPassThruModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 4/18/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBAudioPassThruModuleViewController.h"
#import "RBFilePickerViewController.h"
#import "RBFunctionsViewController.h"

#import "RBParser.h"

static NSString* const NoValueString = @"No Value";

@interface RBAudioPassThruModuleViewController () <SDLProxyListener>

@property (nonatomic, weak) RBFunctionViewController* audioPassThruViewController;
@property (nonatomic, strong) RBFilePickerViewController* filePickerViewController;

@property (nonatomic, strong) SDLPerformAudioPassThru* performAudioPassThru;

@property (nonatomic, weak) IBOutlet UILabel* samplingRateLabel;
@property (nonatomic, weak) IBOutlet UILabel* recordingDurationLabel;
@property (nonatomic, weak) IBOutlet UILabel* bitsPerSampleLabel;
@property (nonatomic, weak) IBOutlet UILabel* muteAudioLabel;

@property (nonatomic, weak) IBOutlet UIButton* sendPerformAudioPassThruButton;
@property (nonatomic, weak) IBOutlet UIButton* endPerformAudioPassThruButton;
@property (nonatomic, weak) UIBarButtonItem* savedAudioFilesButton;

@property (nonatomic, strong) NSMutableData* audioData;

@property (nonatomic, readonly, getter=isValidParametersDictionary) BOOL validParametersDictionary;

@end

@implementation RBAudioPassThruModuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RBFunction* performAudioPassThru = [[RBParser sharedParser] functionOfType:@"PerformAudioPassThru"];
    self.audioPassThruViewController = [RBFunctionsViewController viewControllerForFunction:performAudioPassThru];
    [self.audioPassThruViewController updateView];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    self.filePickerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RBFilePickerViewController"];
    self.filePickerViewController.storageDirectoryPathString = @"AudioFiles/";
    
    UIBarButtonItem* performInteractionSaveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                                     style:UIBarButtonItemStyleDone
                                                                                    target:self
                                                                                    action:@selector(performInteractionSaveAction:)];
    self.audioPassThruViewController.navigationItem.rightBarButtonItem = performInteractionSaveButton;
    [self sdl_updateViewsForParametersDictionary];
    
    UIBarButtonItem* savedAudioFilesButton = [[UIBarButtonItem alloc] initWithTitle:@"Files"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(presentAudioFilesAction:)];
    self.navigationItem.rightBarButtonItem = savedAudioFilesButton;
    self.savedAudioFilesButton = savedAudioFilesButton;
}

#pragma mark - Overrides
+ (NSString*)moduleTitle {
    return @"Audio Pass Through";
}

+ (NSString*)moduleDescription {
    return @"Allows for testing audio pass through capabilities.";
}

+ (NSString*)moduleImageName {
    return @"AudioPassThru";
}

#pragma mark - Getters
- (BOOL)isValidParametersDictionary {
    BOOL isValid = NO;
    NSDictionary* parametersDictionary = self.audioPassThruViewController.parametersDictionary;
    for (NSString* key in parametersDictionary.allKeys) {
        id value = parametersDictionary[key];
        isValid = (value != nil) && ![value isEqual:[NSNull null]];
        if (isValid) {
            break;
        }
    }
    return isValid;
}

#pragma mark - Actions
- (IBAction)editPerformAudioPassThruAction:(id)sender {
    [self.navigationController pushViewController:self.audioPassThruViewController
                                         animated:YES];
}

- (IBAction)sendPerformAudioPassThruAction:(id)sender {
    if (!self.isValidParametersDictionary) {
        UIAlertController* alertController = [UIAlertController simpleErrorAlertWithMessage:@"Please set properties for PerformAudioPassThru before attempting to send it."];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
        return;
    }
    if (![self.proxy.proxyListeners containsObject:self]) {
        [self.proxy addDelegate:self];
    }
    self.sendPerformAudioPassThruButton.enabled = NO;
    self.savedAudioFilesButton.enabled = NO;
    [[SDLManager sharedManager] sendRequestDictionary:self.audioPassThruViewController.requestDictionary
                                             bulkData:nil];
}

- (IBAction)endPerformAudioPassThruAction:(id)sender {
    SDLEndAudioPassThru* endAudioPassThru = [[SDLEndAudioPassThru alloc] init];
    [[SDLManager sharedManager] sendRequest:endAudioPassThru];
}

- (void)performInteractionSaveAction:(id)sender {
    [self.audioPassThruViewController updateRequestsDictionaryFromSubviews];
    [self sdl_updateViewsForParametersDictionary];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)presentAudioFilesAction:(id)sender {
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:self.filePickerViewController];
    [self.navigationController presentViewController:navController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - Delegates
- (void)onOnDriverDistraction:(SDLOnDriverDistraction *)notification { }
- (void)onOnHMIStatus:(SDLOnHMIStatus *)notification { }
- (void)onProxyClosed { }
- (void)onProxyOpened { }

- (void)onOnAudioPassThru:(SDLOnAudioPassThru *)notification {
    if (!self.audioData) {
        self.audioData = [NSMutableData data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.sendPerformAudioPassThruButton.alpha = 0.0f;
                self.endPerformAudioPassThruButton.alpha = 1.0f;
            }];
        });
    } else {
        [self.audioData appendData:[notification.bulkData copy]];
    }
}

- (void)onPerformAudioPassThruResponse:(SDLPerformAudioPassThruResponse *)response {
    if ([response.resultCode isEqualToEnum:SDLResult.SUCCESS]) {
        [self sdl_processAudioData];
    } else {
        self.audioData = nil;
    }
    self.sendPerformAudioPassThruButton.enabled = YES;
    self.savedAudioFilesButton.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.endPerformAudioPassThruButton.alpha = 0.0f;
            self.sendPerformAudioPassThruButton.alpha = 1.0f;
        }];
    });
}

#pragma mark - Private
- (void)sdl_updateViewsForParametersDictionary {
    self.performAudioPassThru = [[SDLManager sharedManager] requestOfClass:[SDLPerformAudioPassThru class]
                                                             forDictionary:self.audioPassThruViewController.requestDictionary
                                                              withBulkData:nil];
    self.samplingRateLabel.text = [self sdl_stringForValue:self.performAudioPassThru.samplingRate];
    NSString* durationString = [self sdl_stringForValue:self.performAudioPassThru.maxDuration];
    if (![durationString isEqualToString:NoValueString]) {
        durationString = [NSString stringWithFormat:@"%@ ms", durationString];
    }
    self.recordingDurationLabel.text = durationString;
    self.bitsPerSampleLabel.text = [self sdl_stringForValue:self.performAudioPassThru.bitsPerSample];
    NSString* muteAudioString = [self sdl_stringForValue:self.performAudioPassThru.muteAudio];
    if ([muteAudioString isEqualToString:NoValueString]) {
        muteAudioString = @"No";
    } else {
        muteAudioString = [muteAudioString isEqualToString:@"0"] ? @"No" : @"Yes";
    }
    self.muteAudioLabel.text = muteAudioString;
}

- (NSString*)sdl_stringForValue:(id)value {
    NSString* stringValue = nil;
    if ([value isKindOfClass:[SDLEnum class]]) {
        SDLEnum* enumObj = (SDLEnum*)value;
        stringValue = enumObj.value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber* numberObj = (NSNumber*)value;
        stringValue = numberObj.stringValue;
    } else {
        stringValue = NoValueString;
    }
    return stringValue;
}

- (void)sdl_processAudioData {
    // save audio data
    NSString* samplingRate = [self sdl_stringForValue:self.performAudioPassThru.samplingRate];
    NSString* duration = [self sdl_stringForValue:self.performAudioPassThru.maxDuration];
    NSString* bitsPerSample = [self sdl_stringForValue:self.performAudioPassThru.bitsPerSample];
    NSString* muteAudio = [self sdl_stringForValue:self.performAudioPassThru.muteAudio];
    if ([muteAudio isEqualToString:NoValueString]) {
        muteAudio = @"UNMUTED";
    } else {
        muteAudio = [muteAudio isEqualToString:@"0"] ? @"UNMUTED" : @"MUTED";
    }
    NSString* timestamp = [NSString stringWithFormat:@"%.f", [[NSDate date] timeIntervalSince1970]];

    NSString* audioDataPathString = [NSString stringWithFormat:@"%@-%@-%@-%@-%@.wav", timestamp, samplingRate, duration, bitsPerSample, muteAudio];
    
    UIAlertController* alertController = nil;
    if ([self.filePickerViewController saveData:self.audioData
                                   withFileName:audioDataPathString]) {
        self.audioData = nil;
        NSString* message = [NSString stringWithFormat:@"Audio file saved as %@", audioDataPathString];
        alertController = [UIAlertController simpleAlertWithTitle:@"Saved"
                                                          message:message];
    } else {
        alertController = [UIAlertController simpleErrorAlertWithMessage:@"Could not save Audio File."];
    }
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
