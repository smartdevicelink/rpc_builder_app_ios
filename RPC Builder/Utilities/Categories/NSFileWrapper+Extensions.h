//
//  NSFileWrapper+Extensions.h
//  RPC Builder
//

#import <Foundation/Foundation.h>

@interface NSFileWrapper (Extensions)

@property (nonatomic, readonly) NSUInteger fileSize;
@property (nonatomic, readonly) NSString* fileSizeString;

@end
