//
//  DeviceInformation.m
//  RPC Builder
//

#import "RBDeviceInformation.h"

@implementation RBDeviceInformation

+ (CGFloat)deviceWidth {
    return CGRectGetWidth([[[UIApplication sharedApplication] keyWindow] bounds]);
}

+ (CGSize)maxViewSize {
    return CGSizeMake([self deviceWidth], CGFLOAT_MAX);
}

@end
