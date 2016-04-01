//
//  NSData+Chunks.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/31/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Chunks)

- (NSArray*)dataChunksOfSize:(NSUInteger)size;

@end
