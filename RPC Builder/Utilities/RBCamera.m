//
//  RBCamera.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 4/3/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBCamera.h"
#import "RBSettingsManager.h"

@interface RBCamera () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession* captureSession;

@end

@implementation RBCamera

- (instancetype)initWithDelegate:(id<RBCameraDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)startCapture {
    [self.captureSession startRunning];
}

- (void)stopCapture {
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
        self.captureSession = nil;
    }
}

#pragma mark - Delegates
#pragma mark AVCaptureVideoDataOutputSampleBuffer
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    if ([self.delegate respondsToSelector:@selector(camera:hasImageBufferAvailable:)]) {
        [self.delegate camera:self hasImageBufferAvailable:imageBuffer];
    }
}

#pragma mark - Getters {
- (AVCaptureSession*)captureSession {
    if (!_captureSession) {
        AVCaptureSession* captureSession = [[AVCaptureSession alloc] init];
        [captureSession beginConfiguration];
        
        captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        
        AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
        dataOutput.alwaysDiscardsLateVideoFrames = YES;
        
        // see if we need this
        dataOutput.videoSettings = @{
                                     (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                                     };
        
        // can we move this somewhere else?
        [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        if ([captureSession canAddOutput:dataOutput]) {
            [captureSession addOutput:dataOutput];
        }
        
        CMTime minFrameRate = CMTimeMake(1, [RBSettingsManager sharedManager].videoStreamingMinimumFrameRate);
        CMTime maxFrameRate = CMTimeMake(1, [RBSettingsManager sharedManager].videoStreamingMaximumFrameRate);
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
            BOOL invalidFrameRate = NO;
            NSString* errorMessage = nil;
            for (AVFrameRateRange* frameRateRange in [[videoDevice activeFormat] videoSupportedFrameRateRanges]) {
                if (frameRateRange.minFrameRate > minFrameRate.timescale) {
                    errorMessage = [NSString stringWithFormat:@"Min frame rate of %d is invalid. It must be greater than or equal to %.1f.", minFrameRate.timescale, frameRateRange.minFrameRate];
                    invalidFrameRate = YES;
                }
                if (frameRateRange.maxFrameRate < maxFrameRate.timescale) {
                    errorMessage = [NSString stringWithFormat:@"Max frame rate of %d is invalid. It must be less than or equal to %.1f.", maxFrameRate.timescale, frameRateRange.maxFrameRate];
                    invalidFrameRate = YES;
                }
                if (invalidFrameRate) {
                    NSError* error = [NSError errorWithDomain:@"com.smartdevicelink.camera" code:0 userInfo:@{NSLocalizedDescriptionKey : errorMessage}];
                    [self sdl_handleError:error];
                    [captureSession commitConfiguration];
                    return nil;
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
            if ([captureSession canAddConnection:connection]) {
                [captureSession addConnection:connection];
            }
        }
        
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        if (error) {
            [self sdl_handleError:error];
            return nil;
        }
        
        if ([captureSession canAddInput:input]) {
            [captureSession addInput:input];
        }
        
        [captureSession commitConfiguration];
        _captureSession = captureSession;
    }
    
    return _captureSession;
}

#pragma mark - Helpers
- (void)sdl_handleError:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(camera:didReceiveError:)]) {
        [self.delegate camera:self didReceiveError:error];
    }
}

@end
