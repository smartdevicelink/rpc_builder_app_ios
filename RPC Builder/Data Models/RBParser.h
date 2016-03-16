//
//  RBParser.h
//  RPC Builder
//

#import <Foundation/Foundation.h>
#import "RBStruct.h"
#import "RBEnum.h"
#import "RBFunction.h"
#import "RBElement.h"
#import "RBParam.h"

typedef NS_ENUM(NSUInteger, RBParserError) {
    RBParserErrorURLNotFound = 404
};

extern NSString* const RBParserErrorStringURLNotFound;

@class RBParser;
@protocol RBParserDelegate <NSObject>

- (void)parserDidFinish:(RBParser*)parser;
- (void)parserErrorOccurred:(RBParser*)parser;

@end

@interface RBParser : NSObject

+ (instancetype)sharedParser;

- (void)parseSpecAtURL:(NSURL*)specURL delegate:(id<RBParserDelegate>)delegate;
- (void)parseSpecData:(NSData*)data delegate:(id<RBParserDelegate>)delegate;

- (RBStruct*)structOfType:(NSString*)type;
- (RBEnum*)enumOfType:(NSString*)type;
- (RBFunction*)functionOfType:(NSString*)type;

@property (weak) id<RBParserDelegate> delegate;

@property (nonatomic, readonly) NSArray* RPCs;
@property (nonatomic, readonly) NSError* error;

@end
