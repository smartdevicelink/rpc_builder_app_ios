//
//  RBCamera.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 4/3/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class RBCamera;

@protocol RBCameraDelegate <NSObject>

- (void)camera:(RBCamera*)camera hasImageBufferAvailable:(CVImageBufferRef)imageBuffer;
- (void)camera:(RBCamera*)camera didReceiveError:(NSError*)error;

@end

@interface RBCamera : NSObject

- (instancetype)initWithDelegate:(id<RBCameraDelegate>)delegate;

- (void)startCapture;
- (void)stopCapture;

@property (weak) id<RBCameraDelegate> delegate;

@end
