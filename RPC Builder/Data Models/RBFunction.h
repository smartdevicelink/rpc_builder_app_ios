//
//  RBFunction.h
//  RPC Builder
//

#import "RBStruct.h"

@interface RBFunction : RBStruct

@property (nonatomic, readonly) NSString* functionID;
@property (nonatomic, readonly) NSString* messageType;

@property (nonatomic, readonly) UIImage* image;

@property (nonatomic, readonly) BOOL requiresBulkData;

@end
