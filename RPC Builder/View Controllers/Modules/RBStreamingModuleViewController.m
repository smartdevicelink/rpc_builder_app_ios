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

@interface RBStreamingModuleViewController ()

@property (nonatomic, weak) IBOutlet UISegmentedControl* audioStreamingTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIView* audioStreamingFileContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* visibleAudioStreamingFileConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* hiddenAudioStreamingFileConstraint;

@property (nonatomic, weak) IBOutlet UISegmentedControl* videoStreamingTypeSegmentedControl;

@property (nonatomic, weak) IBOutlet UIView* videoStreamingCameraContainer;
@property (nonatomic, weak) IBOutlet UIView* videoStreamingFileContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingCameraConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* videoStreamingFileConstraint;

@end

@implementation RBStreamingModuleViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
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

@end
