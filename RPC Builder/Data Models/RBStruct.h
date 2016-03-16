//
//  RBStruct.h
//  RPC Builder
//

#import "RBElement.h"
#import "RBParam.h"

@interface RBStruct : RBElement

- (void)addParameter:(RBParam*)param;

@property (nonatomic, readonly) NSArray* parameters;

@end
