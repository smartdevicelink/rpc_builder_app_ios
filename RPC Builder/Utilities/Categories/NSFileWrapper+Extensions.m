//
//  NSFileWrapper+Extensions.m
//  RPC Builder
//

#import "NSFileWrapper+Extensions.h"

@implementation NSFileWrapper (Extensions)

- (NSUInteger)fileSize {
    return [self.fileAttributes[NSFileSize] unsignedIntegerValue];
}

- (NSString*)fileSizeString {
    return [self.byteFormatter stringFromByteCount:self.fileSize];
}

- (NSByteCountFormatter*)byteFormatter {
    static NSByteCountFormatter* byteFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!byteFormatter) {
            byteFormatter = [[NSByteCountFormatter alloc] init];
            byteFormatter.countStyle = NSByteCountFormatterCountStyleBinary;
        }
    });
    return byteFormatter;
}

@end
