//
//  NSData+Chunks.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 3/31/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "NSData+Chunks.h"

@implementation NSData (Chunks)

- (NSArray*)dataChunksOfSize:(NSUInteger)size {
    NSUInteger chunkCount = MAX(1, ceil(self.length / size));

    NSMutableArray* chunks = [NSMutableArray arrayWithCapacity:chunkCount];
    
    NSUInteger currentIndex = 0;

    while (currentIndex < self.length) {
        NSUInteger dataLength = 0;
        if (currentIndex + size < self.length) {
            dataLength = size;
        } else {
            dataLength = self.length - currentIndex;
        }
        
        NSRange dataRange = NSMakeRange(currentIndex, dataLength);
        NSData* chunk = [self subdataWithRange:dataRange];
        
        [chunks addObject:chunk];
        
        currentIndex += dataLength;
    }
    
    return [chunks copy];
}

@end
