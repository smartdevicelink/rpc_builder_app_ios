//
//  RBStreamingModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBStreamingModuleViewController.h"

#import "RBFilePickerViewController.h"

#import "SDLGlobals.h"

#import "NSData+Chunks.h"
#import <AVFoundation/AVFoundation.h>

static NSInteger const RBLayoutConstraintPriorityHide = 500;
static NSInteger const RBLayoutConstraintPriorityShow = 501;

static CGFloat const RBAnimationDuration = 0.3f;

static NSInteger const RBBufferSizeOffset = 13;

typedef NS_ENUM(NSUInteger, RBStreamingType) {
    RBStreamingTypeDevice,
    RBStreamingTypeFile
};

static NSString* const RBVideoStreamingConnectedKeyPath = @"videoSessionConnected";
static void* RBVideoStreamingConnectedContext = &RBVideoStreamingConnectedContext;

static NSString* const RBAudioStreamingConnectedKeyPath = @"audioSessionConnected";
static void* RBAudioStreamingConnectedContext = &RBAudioStreamingConnectedContext;

@interface RBStreamingModuleViewController () <RBFilePickerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, weak) SDLStreamingMediaManager* streamingManager;
@property (nonatomic, readonly) BOOL isVideoSessionConnected;
@property (nonatomic, readonly) BOOL isAudioSessionConnected;

@property (nonatomic, weak) UILabel* currentFileNameLabel;

@property (nonatomic, readonly) NSUInteger streamingBufferChunkSize;

// Audio Streaming
@property (nonatomic, weak) IBOutlet UIView* audioStreamingFileContainer;
@property (nonatomic, weak) IBOutlet UILabel* audioStreamingFileNameLabel;

@property (nonatomic, weak) IBOutlet UILabel* audioStreamingStatusLabel;
@property (nonatomic, weak) IBOutlet UIButton* audioStreamingButton;

// Audio File Streaming
@property (nonatomic, strong) dispatch_queue_t audioStreamQueue;
@property (nonatomic, strong) NSData* audioStreamingData;
@property (nonatomic) BOOL endAudioStreaming;

// Video Streaming
@property (nonatomic, weak) IBOutlet UISegmentedControl* videoStreamingTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIView* videoStreamingCameraContainer;
@property (nonatomic, weak) IBOutlet UIView* videoStreamingFileContainer;
@property (nonatomic, weak) IBOutlet UILabel* videoStreamingFileNameLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingCameraConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingFileConstraint;

@property (nonatomic, weak) IBOutlet UILabel* videoStreamingStatusLabel;
@property (nonatomic, weak) IBOutlet UIButton* videoStreamingButton;

// Video File Streaming
@property (nonatomic, strong) dispatch_queue_t videoStreamingQueue;
@property (nonatomic, strong) NSData* videoStreamingData;
@property (nonatomic) BOOL endVideoStreaming;

// Video Camera Streaming
@property (nonatomic, strong) AVCaptureSession* captureSession;

@end

@implementation RBStreamingModuleViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.streamingManager) {
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

- (void)viewWillDisappear:(BOOL)animated {
    [self.streamingManager removeObserver:self
                               forKeyPath:RBVideoStreamingConnectedKeyPath];
    [self.streamingManager removeObserver:self
                               forKeyPath:RBAudioStreamingConnectedKeyPath];
    [super viewWillDisappear:animated];
}

#pragma mark - Overrides
+ (NSString*)moduleTitle {
    return @"Streaming";
}

+ (NSString*)moduleDescription {
    return @"Allows for testing of audio and video streaming. If streaming a file, only certain file types are currently supported. For closest to production functionality, please stream from Microphone/Camera.";
}

+ (NSString*)moduleImageName {
    return nil;
}

+ (NSString*)minimumSupportedVersion {
    return @"8.0";
}

#pragma mark - Getters
- (BOOL)isAudioSessionConnected {
    return self.streamingManager.audioSessionConnected;
}

- (BOOL)isVideoSessionConnected {
    return self.streamingManager.videoSessionConnected;
}

- (NSUInteger)streamingBufferChunkSize {
    return [[SDLGlobals globals] maxMTUSize] - RBBufferSizeOffset;
}

#pragma mark - Setters
- (void)setProxy:(SDLProxy *)proxy {
    [super setProxy:proxy];
    self.streamingManager = proxy.streamingMediaManager;
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
        __weak typeof(self) weakSelf = self;
        [self.streamingManager startAudioStreamingWithStartBlock:^(BOOL success, NSError * _Nullable error) {
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

#pragma mark AVCaptureVideoDataOutputSampleBuffer
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    if (self.isVideoSessionConnected) {
        [self.streamingManager sendVideoData:pixelBuffer];
    }
}

#pragma mark - Helpers
- (void)sdl_presentFilePickerViewController {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                         bundle:nil];
    RBFilePickerViewController* filePickerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RBFilePickerViewController"];
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

- (void)sdl_updateView:(UIView*)view withEnabledState:(BOOL)enabled {
    view.userInteractionEnabled = enabled;
    if (view.alpha > 0.0) {
        view.alpha = enabled ? 1.0 : 0.5;
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
            case SDLSTreamingVideoErrorInvalidOperatingSystemVersion:
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
    
    UIAlertController* alertController = [UIAlertController simpleErrorAlertWithMessage:errorString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    });
}

- (void)sdl_beginVideoStreaming {
    if (self.videoStreamingTypeSegmentedControl.selectedSegmentIndex == RBStreamingTypeDevice) {
        
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession beginConfiguration];
        
        self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        
        AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

        AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        dataOutput.alwaysDiscardsLateVideoFrames = YES;
        
        // see if we need this
        dataOutput.videoSettings = @{
                                     (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                                     };
        
        // can we move this somewhere else?
        [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        if ([self.captureSession canAddOutput:dataOutput]) {
            [self.captureSession addOutput:dataOutput];
        }
        
        CMTime minFrameRate = CMTimeMake(1, 1);
        CMTime maxFrameRate = CMTimeMake(1, 30);
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
            BOOL invalidFrameRate = NO;
            NSString* errorTitle = nil;
            NSString* errorMessage = nil;
            for (AVFrameRateRange* frameRateRange in [[videoDevice activeFormat] videoSupportedFrameRateRanges]) {
                if (frameRateRange.minFrameRate > minFrameRate.timescale) {
                    errorTitle = @"Min Frame Rate Error";
                    errorMessage = [NSString stringWithFormat:@"Min frame rate of %d is invalid. It must be greater than or equal to %.1f.", minFrameRate.timescale, frameRateRange.minFrameRate];
                    invalidFrameRate = YES;
                }
                if (frameRateRange.maxFrameRate < maxFrameRate.timescale) {
                    errorTitle = @"Max Frame Rate Error";
                    errorMessage = [NSString stringWithFormat:@"Max frame rate of %d is invalid. It must be less than or equal to %.1f.", maxFrameRate.timescale, frameRateRange.maxFrameRate];
                    invalidFrameRate = YES;
                }
                if (invalidFrameRate) {
                    UIAlertController* alertController = [UIAlertController simpleAlertWithTitle:errorTitle
                                                                                         message:errorMessage];
                    [self presentViewController:alertController
                                       animated:YES
                                     completion:nil];
                    [self.captureSession commitConfiguration];
                    return;
                }
            }
            [videoDevice lockForConfiguration:nil];
            [videoDevice setActiveVideoMinFrameDuration:maxFrameRate];
            [videoDevice setActiveVideoMaxFrameDuration:minFrameRate];
            [videoDevice unlockForConfiguration];
        } else {
            AVCaptureConnection* connection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
            if (connection.isVideoMinFrameDurationSupported) {
                connection.videoMinFrameDuration = maxFrameRate;
            }
            if (connection.isVideoMaxFrameDurationSupported) {
                connection.videoMaxFrameDuration = minFrameRate;
            }
            if ([self.captureSession canAddConnection:connection]) {
                [self.captureSession addConnection:connection];
            }
        }
        
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (error) {
            [self sdl_handleError:error];
        }
        
        if ([self.captureSession canAddInput:input]) {
            [self.captureSession addInput:input];
        }
        
        [self.captureSession commitConfiguration];
        
        [self.captureSession startRunning];
    } else {
        self.videoStreamingQueue = dispatch_queue_create("com.smartdevicelink.videostreaming",
                                                         DISPATCH_QUEUE_SERIAL);

        NSArray* videoChunks = [self.videoStreamingData dataChunksOfSize:self.streamingBufferChunkSize];
        
        dispatch_async(self.videoStreamingQueue, ^{
            while (!self.endVideoStreaming) {
                for (NSData* chunk in videoChunks) {
                    // We send raw data because there are so many possible types of files,
                    // it's easier for us to just send raw data, and let Core try to
                    // reassemble it. SDLStreamingMediaManager actually takes
                    // CVImageBufferRefs and converts them to NSData and sends them off
                    // using SDLProtocol's sendRawData:withServiceType:.
                    [self.proxy.protocol sendRawData:chunk
                                     withServiceType:SDLServiceType_Video];
                    
                    [NSThread sleepForTimeInterval:0.25];
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
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
    self.endVideoStreaming = YES;
    self.videoStreamingQueue = nil;
}

- (void)sdl_beginAudioStreaming {
    self.audioStreamQueue = dispatch_queue_create("com.smartdevicelink.audiostreaming",
                                                     DISPATCH_QUEUE_SERIAL);
    
    NSArray* audioChunks = [self.audioStreamingData dataChunksOfSize:self.streamingBufferChunkSize];
    
    dispatch_async(self.audioStreamQueue, ^{
        while (!self.endAudioStreaming) {
            for (NSData* chunk in audioChunks) {
                [self.streamingManager sendAudioData:chunk];
                
                [NSThread sleepForTimeInterval:0.25];
            }
        }
        
        self.endAudioStreaming = NO;
    });
}

- (void)sdl_endAudioStreaming {
    [self.streamingManager stopAudioSession];
}

- (void)sdl_handleEmptyStreamingDataError {
    UIAlertController* alertController = [UIAlertController simpleErrorAlertWithMessage:@"Cannot start stream. Streaming data is empty."];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == RBAudioStreamingConnectedContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sdl_updateLabel:self.audioStreamingStatusLabel
                forConnectedState:self.isAudioSessionConnected];
            [self sdl_updateView:self.audioStreamingFileContainer
                withEnabledState:!self.isAudioSessionConnected];
            [self sdl_updateButton:self.audioStreamingButton
                 forConnectedState:self.isAudioSessionConnected];
        });
    } else if (context == RBVideoStreamingConnectedContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sdl_updateLabel:self.videoStreamingStatusLabel
                forConnectedState:self.isVideoSessionConnected];
            self.videoStreamingTypeSegmentedControl.enabled = !self.isVideoSessionConnected;
            [self sdl_updateView:self.videoStreamingFileContainer
                withEnabledState:!self.isVideoSessionConnected];
            [self sdl_updateView:self.videoStreamingCameraContainer
                withEnabledState:!self.isVideoSessionConnected];
            [self sdl_updateButton:self.videoStreamingButton
                 forConnectedState:self.isVideoSessionConnected];
        });
    }
}

@end
