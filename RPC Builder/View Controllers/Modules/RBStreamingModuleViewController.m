//
//  RBStreamingModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBStreamingModuleViewController.h"
#import "RBFilePickerViewController.h"

#import "NSData+Chunks.h"

#import "RBCamera.h"

static NSInteger const RBLayoutConstraintPriorityHide = 500;
static NSInteger const RBLayoutConstraintPriorityShow = 501;

static CGFloat const RBAnimationDuration = 0.3f;

typedef NS_ENUM(NSUInteger, RBStreamingType) {
    RBStreamingTypeDevice,
    RBStreamingTypeFile
};

static NSString* const RBVideoStreamingConnectedKeyPath = @"videoSessionConnected";
static void* RBVideoStreamingConnectedContext = &RBVideoStreamingConnectedContext;

static NSString* const RBAudioStreamingConnectedKeyPath = @"audioSessionConnected";
static void* RBAudioStreamingConnectedContext = &RBAudioStreamingConnectedContext;

@interface RBStreamingModuleViewController () <RBFilePickerDelegate, RBCameraDelegate, UITextFieldDelegate>

@property (nonatomic, readonly) SDLStreamingMediaManager* streamingManager;
@property (nonatomic, readonly) BOOL isVideoSessionConnected;
@property (nonatomic, readonly) BOOL isAudioSessionConnected;

@property (nonatomic, getter=isObservingStreaming) BOOL observingStreaming;

@property (nonatomic, weak) UILabel* currentFileNameLabel;

@property (nonatomic, readonly) NSNumberFormatter* unsignedIntegerNumberFormatter;
@property (nonatomic, readonly) NSNumberFormatter* decimalNumberFormatter;

// Audio Streaming
@property (nonatomic, weak) IBOutlet UIView* audioStreamingFileContainer;
@property (nonatomic, weak) IBOutlet UILabel* audioStreamingFileNameLabel;
@property (nonatomic, weak) IBOutlet UITextField* audioStreamingBufferSizeTextField;

@property (nonatomic, weak) IBOutlet UILabel* audioStreamingStatusLabel;
@property (nonatomic, weak) IBOutlet UIButton* audioStreamingButton;

// Audio File Streaming
@property (nonatomic, strong) dispatch_queue_t audioStreamQueue;
@property (nonatomic, strong) NSData* audioStreamingData;
@property (nonatomic) BOOL endAudioStreaming;

// Video Streaming
@property (nonatomic, weak) IBOutlet UISegmentedControl* videoStreamingTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIView* videoStreamingCameraContainer;
@property (nonatomic, weak) IBOutlet UITextField* videoStreamingMinFrameRateTextField;
@property (nonatomic, weak) IBOutlet UITextField* videoStreamingMaxFrameRateTextField;

@property (nonatomic, weak) IBOutlet UIView* videoStreamingFileContainer;
@property (nonatomic, weak) IBOutlet UILabel* videoStreamingFileNameLabel;
@property (nonatomic, weak) IBOutlet UITextField* videoStreamingBufferSizeTextField;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingCameraConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingFileConstraint;

@property (nonatomic, weak) IBOutlet UILabel* videoStreamingStatusLabel;
@property (nonatomic, weak) IBOutlet UIButton* videoStreamingButton;

// Video File Streaming
@property (nonatomic, strong) dispatch_queue_t videoStreamingQueue;
@property (nonatomic, strong) NSData* videoStreamingData;
@property (nonatomic) BOOL endVideoStreaming;

// Video Camera Streaming
@property (nonatomic, strong) RBCamera* camera;

@end

@implementation RBStreamingModuleViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.streamingManager) {
        NSKeyValueObservingOptions observations = (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew);
        [self.manager addObserver:self
                     forKeyPath:SDLManagerConnectedKeyPath
                        options:observations
                        context:&SDLManagerConnectedContext];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.streamingManager) {
        [self.manager removeObserver:self
                             forKeyPath:SDLManagerConnectedKeyPath];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.audioStreamingBufferSizeTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.settingsManager.audioStreamingBufferSize];
    self.videoStreamingBufferSizeTextField.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.settingsManager.videoStreamingBufferSize];
    
    self.videoStreamingMinFrameRateTextField.text = [NSString stringWithFormat:@"%.02f", self.settingsManager.videoStreamingMinimumFrameRate];
    self.videoStreamingMaxFrameRateTextField.text = [NSString stringWithFormat:@"%.02f", self.settingsManager.videoStreamingMaximumFrameRate];
}

#pragma mark - Overrides
+ (NSString*)moduleTitle {
    return @"Streaming";
}

+ (NSString*)moduleDescription {
    return @"Allows for testing of audio and video streaming. For streaming video files, make sure the file is h.264 encoded.";
}

+ (NSString*)moduleImageName {
    return @"Streaming";
}

+ (NSString*)minimumSupportedVersion {
    return @"8.0";
}

#pragma mark - Getters
- (SDLStreamingMediaManager*)streamingManager {
    return self.proxy.streamingMediaManager;
}

- (BOOL)isAudioSessionConnected {
    return self.manager.isConnected ? self.streamingManager.audioSessionConnected : NO;
}

- (BOOL)isVideoSessionConnected {
    return self.manager.isConnected ? self.streamingManager.videoSessionConnected : NO;
}

- (NSNumberFormatter*)decimalNumberFormatter {
    static NSNumberFormatter* decimalNumberFormatter = nil;
    if (!decimalNumberFormatter) {
        decimalNumberFormatter = [[NSNumberFormatter alloc] init];
        decimalNumberFormatter.numberStyle = kCFNumberFormatterDecimalStyle;
    }
    return decimalNumberFormatter;
}

- (NSNumberFormatter*)unsignedIntegerNumberFormatter {
    static NSNumberFormatter* unsignedIntegerNumberFormatter = nil;
    if (!unsignedIntegerNumberFormatter) {
        unsignedIntegerNumberFormatter = [[NSNumberFormatter alloc] init];
    }
    return unsignedIntegerNumberFormatter;
}

#pragma mark - Actions
- (IBAction)segmentedControlIndexDidChange:(id)sender {
    [self.view endEditing:YES];
    if (sender == self.videoStreamingTypeSegmentedControl) {
        if (self.videoStreamingTypeSegmentedControl.selectedSegmentIndex == RBStreamingTypeDevice) {
            [self sdl_showVideoStreamingCameraContainer];
        } else {
            [self sdl_showVideoStreamingFileContainer];
        }
    }
}

- (IBAction)videoStreamingAction:(id)sender {
    if (self.streamingManager.videoSessionConnected) {
        [self sdl_endVideoStreaming];
    } else {
        if (self.videoStreamingTypeSegmentedControl.selectedSegmentIndex == RBStreamingTypeFile
            && !self.videoStreamingData) {
            [self sdl_handleEmptyStreamingDataError];
            return;
        }
        if (!self.manager.isConnected) {
            [self sdl_handleProxyNotConnectedError];
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self.streamingManager startVideoSessionWithStartBlock:^(BOOL success, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;
            if (!success) {
                [strongSelf sdl_handleError:error];
            } else {
                [strongSelf sdl_beginVideoStreaming];
            }
        }];
    }
}

- (IBAction)audioStreamingAction:(id)sender {
    if (self.streamingManager.audioSessionConnected) {
        [self sdl_endAudioStreaming];
    } else {
        if (!self.audioStreamingData) {
            [self sdl_handleEmptyStreamingDataError];
            return;
        }
        if (!self.manager.isConnected) {
            [self sdl_handleProxyNotConnectedError];
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self.streamingManager startAudioSessionWithStartBlock:^(BOOL success, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;
            if (!success) {
                [strongSelf sdl_handleError:error];
            } else {
                [strongSelf sdl_beginAudioStreaming];
            }
        }];
    }
}

- (IBAction)selectAudioStreamingFileAction:(id)sender {
    self.currentFileNameLabel = self.audioStreamingFileNameLabel;
    [self sdl_presentFilePickerViewController];
}

- (IBAction)selectVideoStreamingFileAction:(id)sender {
    self.currentFileNameLabel = self.videoStreamingFileNameLabel;
    [self sdl_presentFilePickerViewController];
}

#pragma mark - Delegates
#pragma mark RBFilePickerViewController
- (void)filePicker:(RBFilePickerViewController *)picker didSelectFileNamed:(NSString *)fileName withData:(NSData *)data {
    self.currentFileNameLabel.text = fileName;
    if (self.currentFileNameLabel == self.videoStreamingFileNameLabel) {
        self.videoStreamingData = data;
    } else {
        self.audioStreamingData = data;
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        self.currentFileNameLabel = nil;
    }];
}

#pragma mark RBCamera
- (void)camera:(RBCamera *)camera didReceiveError:(NSError *)error {
    [self sdl_handleError:error];
}

- (void)camera:(RBCamera *)camera hasImageBufferAvailable:(CVImageBufferRef)imageBuffer {
    if (self.isVideoSessionConnected) {
        [self.streamingManager sendVideoData:imageBuffer];
    }
}

#pragma mark UITextField
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.audioStreamingBufferSizeTextField) {
        NSNumber* number = [self.unsignedIntegerNumberFormatter numberFromString:self.audioStreamingBufferSizeTextField.text];
        self.settingsManager.audioStreamingBufferSize = [number unsignedIntegerValue];
    } else if (textField == self.videoStreamingBufferSizeTextField) {
        NSNumber* number = [self.unsignedIntegerNumberFormatter numberFromString:self.videoStreamingBufferSizeTextField.text];
        self.settingsManager.videoStreamingBufferSize = [number unsignedIntegerValue];
    } else if (textField == self.videoStreamingMinFrameRateTextField) {
        NSNumber* number = [self.decimalNumberFormatter numberFromString:self.videoStreamingMinFrameRateTextField.text];
        self.settingsManager.videoStreamingMinimumFrameRate = [number floatValue];
    } else if (textField == self.videoStreamingMaxFrameRateTextField) {
        NSNumber* number = [self.decimalNumberFormatter numberFromString:self.videoStreamingMaxFrameRateTextField.text];
        self.settingsManager.videoStreamingMaximumFrameRate = [number floatValue];
    }
}

#pragma mark - Helpers
- (void)sdl_presentFilePickerViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    RBFilePickerViewController* filePickerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RBFilePickerViewController"];
    filePickerViewController.storageDirectoryPathString = @"BulkData/";
    filePickerViewController.delegate = self;
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:filePickerViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)sdl_showViewsWithAlphaAnimations:(void (^)(void))animations {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [UIView animateKeyframesWithDuration:RBAnimationDuration delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/2.0 animations:^{
                [self.view layoutIfNeeded];
            }];
            [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:animations];
        } completion:nil];
    } else {
        [UIView animateWithDuration:RBAnimationDuration animations:^{
            [self.view layoutIfNeeded];
            if (animations) {
                animations();
            }
        }];
    }
}

- (void)sdl_showVideoStreamingCameraContainer {
    _videoStreamingFileConstraint.priority = RBLayoutConstraintPriorityHide;
    _videoStreamingCameraConstraint.priority = RBLayoutConstraintPriorityShow;
    [self sdl_showViewsWithAlphaAnimations:^{
        _videoStreamingFileContainer.alpha = 0.0f;
        _videoStreamingCameraContainer.alpha = 1.0f;
    }];
}

- (void)sdl_showVideoStreamingFileContainer {
    _videoStreamingFileConstraint.priority = RBLayoutConstraintPriorityShow;
    _videoStreamingCameraConstraint.priority = RBLayoutConstraintPriorityHide;
    [self sdl_showViewsWithAlphaAnimations:^{
        _videoStreamingFileContainer.alpha = 1.0f;
        _videoStreamingCameraContainer.alpha = 0.0f;
    }];
}

- (void)sdl_updateAudioStreamingViews {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sdl_updateLabel:self.audioStreamingStatusLabel
            forConnectedState:self.isAudioSessionConnected];
        [self sdl_updateView:self.audioStreamingFileContainer
           forConnectedState:self.isAudioSessionConnected];
        [self sdl_updateButton:self.audioStreamingButton
             forConnectedState:self.isAudioSessionConnected];
    });
}

- (void)sdl_updateVideoStreamingViews {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sdl_updateLabel:self.videoStreamingStatusLabel
            forConnectedState:self.isVideoSessionConnected];
        self.videoStreamingTypeSegmentedControl.enabled = !self.isVideoSessionConnected;
        [self sdl_updateView:self.videoStreamingFileContainer
           forConnectedState:self.isVideoSessionConnected];
        [self sdl_updateView:self.videoStreamingCameraContainer
           forConnectedState:self.isVideoSessionConnected];
        [self sdl_updateButton:self.videoStreamingButton
             forConnectedState:self.isVideoSessionConnected];
    });
}


- (void)sdl_updateView:(UIView*)view forConnectedState:(BOOL)connected {
    view.userInteractionEnabled = !connected;
    if (view.alpha > 0.0) {
        view.alpha = connected ? 0.5 : 1.0;
    }
}

- (void)sdl_updateLabel:(UILabel*)label forConnectedState:(BOOL)connected {
    label.text = connected ? @"Connected" : @"Disconnected";
}

- (void)sdl_updateButton:(UIButton*)button forConnectedState:(BOOL)connected {
    button.enabled = YES;
    [button setTitle:connected ? @"Stop Streaming" : @"Start Streaming"
            forState:UIControlStateNormal];
}

- (void)sdl_handleError:(NSError*)error {
    NSString* errorString = error.localizedDescription;
    NSString* systemErrorCode = error.userInfo[@"OSStatus"];
    if ([error.domain isEqualToString:SDLErrorDomainStreamingMediaAudio]) {
        switch (error.code) {
            case SDLStreamingAudioErrorHeadUnitNACK:
                errorString = @"Audio Streaming did not receive acknowledgement from Core.";
                break;
            default:
                break;
        }
    } else if ([error.domain isEqualToString:SDLErrorDomainStreamingMediaVideo]) {
        switch (error.code) {
            case SDLStreamingVideoErrorHeadUnitNACK:
                errorString = @"Video Streaming did not receive acknowledgement from Core.";
                break;
            case SDLStreamingVideoErrorInvalidOperatingSystemVersion:
                errorString = @"Video Streaming can only be run on iOS 8+ devices.";
                break;
            case SDLStreamingVideoErrorConfigurationCompressionSessionCreationFailure:
                errorString = @"Could not create Video Streaming compression session.";
                break;
            case SDLStreamingVideoErrorConfigurationAllocationFailure:
                errorString = @"Could not allocate Video Streaming configuration.";
                break;
            case SDLStreamingVideoErrorConfigurationCompressionSessionSetPropertyFailure:
                errorString = @"Could not set property for Video Streaming configuration.";
                break;
            default:
                break;
        }
    }
    
    if (systemErrorCode) {
        errorString = [NSString stringWithFormat:@"%@ %@", errorString, systemErrorCode];
    }
    
    [self sdl_presentErrorWithMessage:errorString];
}

- (void)sdl_beginVideoStreaming {
    if (self.videoStreamingTypeSegmentedControl.selectedSegmentIndex == RBStreamingTypeDevice) {
        if (!self.camera) {
            self.camera = [[RBCamera alloc] initWithDelegate:self];
        }
        
        [self.camera startCapture];
    } else {
        self.videoStreamingQueue = dispatch_queue_create("com.smartdevicelink.videostreaming",
                                                         DISPATCH_QUEUE_SERIAL);

        NSArray* videoChunks = [self.videoStreamingData dataChunksOfSize:self.settingsManager.videoStreamingBufferSize];
        
        dispatch_async(self.videoStreamingQueue, ^{
            while (!self.endVideoStreaming) {
                for (NSData* chunk in videoChunks) {
                    // We send raw data because there are so many possible types of files,
                    // it's easier for us to just send raw data, and let Core try to
                    // reassemble it. SDLStreamingMediaManager actually takes
                    // CVImageBufferRefs and converts them to NSData and sends them off
                    // using SDLProtocol's sendRawData:withServiceType:.
                    if (self.isVideoSessionConnected) {
                        [self.proxy.protocol sendRawData:chunk
                                         withServiceType:SDLServiceType_Video];
                        
                        [NSThread sleepForTimeInterval:0.25];
                    } else {
                        self.endVideoStreaming = YES;
                        break;
                    }
                }
            }
            
            self.endVideoStreaming = NO;
        });
    }
}

- (void)sdl_endVideoStreaming {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoStreamingStatusLabel.text = @"Disconnecting…";
        self.videoStreamingButton.enabled = NO;
    });
    
    [self.streamingManager stopVideoSession];
    [self.camera stopCapture];
    
    self.endVideoStreaming = YES;
    self.videoStreamingQueue = nil;
}

- (void)sdl_beginAudioStreaming {
    self.audioStreamQueue = dispatch_queue_create("com.smartdevicelink.audiostreaming",
                                                     DISPATCH_QUEUE_SERIAL);
    
    NSArray* audioChunks = [self.audioStreamingData dataChunksOfSize:self.settingsManager.audioStreamingBufferSize];
    
    dispatch_async(self.audioStreamQueue, ^{
        while (!self.endAudioStreaming) {
            for (NSData* chunk in audioChunks) {
                if (self.isAudioSessionConnected) {
                    [self.streamingManager sendAudioData:chunk];
                    
                    [NSThread sleepForTimeInterval:0.25];
                } else {
                    self.endAudioStreaming = YES;
                    break;
                }
            }
        }
        
        self.endAudioStreaming = NO;
    });
}

- (void)sdl_endAudioStreaming {
    [self.streamingManager stopAudioSession];
}

- (void)sdl_handleEmptyStreamingDataError {
    [self sdl_presentErrorWithMessage:@"Cannot start stream. Streaming data is empty."];
}

- (void)sdl_handleProxyNotConnectedError {
    [self sdl_presentErrorWithMessage:@"Cannot start streaming. Not connected to Core."];
}

- (void)sdl_presentErrorWithMessage:(NSString*)message {
    UIAlertController* alertController = [UIAlertController simpleErrorAlertWithMessage:message];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    });
}

- (void)sdl_addStreamingObservers {
    if (!self.isObservingStreaming) {
        self.observingStreaming = YES;
        NSKeyValueObservingOptions observations = (NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew);
        [self.streamingManager addObserver:self
                                forKeyPath:RBVideoStreamingConnectedKeyPath
                                   options:observations
                                   context:&RBVideoStreamingConnectedContext];
        [self.streamingManager addObserver:self
                                forKeyPath:RBAudioStreamingConnectedKeyPath
                                   options:observations
                                   context:&RBAudioStreamingConnectedContext];
    }
}

- (void)sdl_removeStreamingObservers {
    if (self.isObservingStreaming) {
        self.observingStreaming = NO;
        [self.streamingManager removeObserver:self
                                   forKeyPath:RBVideoStreamingConnectedKeyPath];
        [self.streamingManager removeObserver:self
                                   forKeyPath:RBAudioStreamingConnectedKeyPath];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == SDLManagerConnectedContext) {
        if (!self.manager.isConnected) {
            [self sdl_removeStreamingObservers];
        } else {
            [self sdl_addStreamingObservers];
        }
    } else if (context == RBAudioStreamingConnectedContext) {
        [self sdl_updateAudioStreamingViews];
    } else if (context == RBVideoStreamingConnectedContext) {
        [self sdl_updateVideoStreamingViews];
    }
}

@end
