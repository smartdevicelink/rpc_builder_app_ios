//
//  RBStreamingModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/29/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBStreamingModuleViewController.h"

static NSInteger const RBLayoutConstraintPriorityHide = 500;
static NSInteger const RBLayoutConstraintPriorityShow = 501;

static CGFloat const RBAnimationDuration = 0.3f;

static NSString* const RBVideoStreamingConnectedKeyPath = @"videoSessionConnected";
static void* RBVideoStreamingConnectedContext = &RBVideoStreamingConnectedContext;

static NSString* const RBAudioStreamingConnectedKeyPath = @"audioSessionConnected";
static void* RBAudioStreamingConnectedContext = &RBAudioStreamingConnectedContext;

@interface RBStreamingModuleViewController ()

@property (nonatomic, weak) SDLStreamingMediaManager* streamingManager;
@property (nonatomic, readonly) BOOL isVideoSessionConnected;
@property (nonatomic, readonly) BOOL isAudioSessionConnected;

@property (nonatomic, weak) IBOutlet UISegmentedControl* audioStreamingTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIView* audioStreamingFileContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* visibleAudioStreamingFileConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* hiddenAudioStreamingFileConstraint;

@property (nonatomic, weak) IBOutlet UILabel* audioStreamingStatusLabel;

@property (nonatomic, weak) IBOutlet UISegmentedControl* videoStreamingTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIView* videoStreamingCameraContainer;
@property (nonatomic, weak) IBOutlet UIView* videoStreamingFileContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingCameraConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingFileConstraint;

@property (nonatomic, weak) IBOutlet UILabel* videoStreamingStatusLabel;

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
    return @"Allows for testing of audio and video streaming. Audio streaming will stream from the microphone, and video streaming will occur from the camera.";
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

#pragma mark - Setters
- (void)setProxy:(SDLProxy *)proxy {
    [super setProxy:proxy];
    self.streamingManager = proxy.streamingMediaManager;
}

#pragma mark - Actions
- (IBAction)segmentedControlIndexDidChange:(id)sender {
    [self.view endEditing:YES];
    if (sender == self.audioStreamingTypeSegmentedControl) {
        if (self.audioStreamingTypeSegmentedControl.selectedSegmentIndex == 0) {
            [self sdl_hideAudioStreamingFileContainer];
        } else {
            [self sdl_showAudioStreamingFileContainer];
        }
    } else if (sender == self.videoStreamingTypeSegmentedControl) {
        if (self.videoStreamingTypeSegmentedControl.selectedSegmentIndex == 0) {
            [self sdl_showVideoStreamingCameraContainer];
        } else {
            [self sdl_showVideoStreamingFileContainer];
        }
    }
}

- (IBAction)videoStreamingAction:(id)sender {
    if (self.streamingManager.videoSessionConnected) {
        [self.streamingManager stopVideoSession];
    } else {
        __weak typeof(self) weakSelf = self;
        [self.streamingManager startVideoSessionWithStartBlock:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"success!");
            } else {
                typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf sdl_handleError:error];
            }
        }];
    }
}

- (IBAction)audioStreamingAction:(id)sender {
    if (self.streamingManager.audioSessionConnected) {
        [self.streamingManager stopAudioSession];
    } else {
        __weak typeof(self) weakSelf = self;
        [self.streamingManager startAudioStreamingWithStartBlock:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"success!");
            } else {
                typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf sdl_handleError:error];
            }
        }];
    }
}

#pragma mark - Helpers
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

- (void)sdl_hideAudioStreamingFileContainer {
    _visibleAudioStreamingFileConstraint.priority = RBLayoutConstraintPriorityHide;
    _hiddenAudioStreamingFileConstraint.priority = RBLayoutConstraintPriorityShow;
    // The convenience method above doesn't look great for hiding but not replacing.
    [UIView animateKeyframesWithDuration:RBAnimationDuration delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:^{
            [self.view layoutIfNeeded];
        }];
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/2.0 animations:^{
            _audioStreamingFileContainer.alpha = 0.0f;
        }];
    } completion:nil];
}

- (void)sdl_showAudioStreamingFileContainer {
    _visibleAudioStreamingFileConstraint.priority = RBLayoutConstraintPriorityShow;
    _hiddenAudioStreamingFileConstraint.priority = RBLayoutConstraintPriorityHide;
    [self sdl_showViewsWithAlphaAnimations:^{
        _audioStreamingFileContainer.alpha = 1.0f;
    }];
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

- (void)sdl_handleError:(NSError*)error {
    NSString* errorString = @"Unknown Error Occurred";
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (context == RBAudioStreamingConnectedContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sdl_updateLabel:self.audioStreamingStatusLabel
                forConnectedState:self.isAudioSessionConnected];
            self.audioStreamingTypeSegmentedControl.enabled = !self.isAudioSessionConnected;
            [self sdl_updateView:self.audioStreamingFileContainer
                withEnabledState:!self.isAudioSessionConnected];
            
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
        });
    }
}

@end
