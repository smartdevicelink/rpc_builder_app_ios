//
//  RBSpecFile.h
//  RPC Builder
//

#import <Foundation/Foundation.h>

@class RBSpecFile;

@protocol RBSpecFileDelegate <NSObject>

- (void)specFile:(RBSpecFile*)file fetchUrlDidFinishWithError:(NSError*)error;
- (void)specFileFetchUrlDidFinish:(RBSpecFile*)file;

@end

@interface RBSpecFile : NSObject

- (instancetype)initWithURL:(NSURL*)url;
+ (instancetype)fileWithURL:(NSURL*)url;

- (void)fetchUrl;

@property (nonatomic, readonly) NSString* fileName;
@property (nonatomic, readonly) NSURL* url;
@property (nonatomic, readonly) NSData* data;

@property (weak) id<RBSpecFileDelegate> delegate;

@end
