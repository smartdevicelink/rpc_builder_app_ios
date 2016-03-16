//
//  RBEnum.h
//  RPC Builder
//

#import "RBBaseObject.h"

@class RBElement;

@interface RBEnum : RBBaseObject

- (void)addElement:(RBElement*)element;

@property (nonatomic, readonly) NSArray* elements;

@end