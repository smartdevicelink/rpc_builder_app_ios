//
//  RBSpecFile.m
//  RPC Builder
//

#import "RBSpecFile.h"

@interface RBSpecFile ()

@property (nonatomic, readonly) NSString* documentsPathString;

@end

@implementation RBSpecFile

+ (instancetype)fileWithURL:(NSURL*)url {
    return [[RBSpecFile alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        
        NSString *documentsPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        documentsPathString = [documentsPathString stringByAppendingString:@"/SpecXMLs/"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPathString]) {
            NSError* error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:documentsPathString
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                [self.delegate specFile:self fetchUrlDidFinishWithError:error];
            }
        }
        _documentsPathString = documentsPathString;
    }
    return self;
}

#pragma mark - Overrides
- (BOOL)isEqual:(id)object {
    BOOL isEqual = NO;
    if ([object isKindOfClass:[RBSpecFile class]]) {
        RBSpecFile* file = (RBSpecFile*)object;
        isEqual = [self.url isEqual:file.url]
                  || [self.url.lastPathComponent isEqualToString:file.url.lastPathComponent];
        isEqual &= [self.fileName isEqualToString:file.fileName];
    }
    return isEqual;
}

#pragma mark - Public Functions
- (void)fetchUrl {
    if ([self.url scheme] && ![self.url isFileURL]) {
        [self sdl_fetchRemoteURL:self.url];
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.url.path]) {
            [self sdl_fetchURL:self.url];
        } else {
            [self sdl_fetchBundleURL:self.url];
        }
    }
}

#pragma mark - Getters
- (NSString*)fileName {
    return [self.url lastPathComponent];
}

#pragma mark - Private
#pragma mark Helpers
- (void)sdl_fetchBundleURL:(NSURL*)url {
    NSString* lastPathComponent = [url lastPathComponent];
    NSURL* bundleURL = [[NSBundle mainBundle] URLForResource:[lastPathComponent stringByDeletingPathExtension]
                                               withExtension:[lastPathComponent pathExtension]];
    [self sdl_fetchURL:bundleURL];
}

- (void)sdl_fetchURL:(NSURL*)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData* fileData = [NSData dataWithContentsOfURL:url];
        if (fileData) {
            _data = fileData;
            [self sdl_didFinish];
        } else {
            NSString* errorString = [NSString stringWithFormat:@"File not found at %@", url.absoluteString];
            NSError* error = [NSError errorWithDomain:@"com.smartdevicelink.RBSpecFile"
                                                 code:404
                                             userInfo:@{NSLocalizedDescriptionKey : errorString}];
            [self sdl_didFinishWithError:error];
        }
    });
}

- (void)sdl_fetchRemoteURL:(NSURL*)url {
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    [[session downloadTaskWithURL:self.url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (location) {
            NSError* saveError = nil;
            NSURL* documentsPath = [NSURL fileURLWithPath:self.documentsPathString];
            NSString* fileName = [NSString stringWithFormat:@"%f-spec.xml", [[NSDate date] timeIntervalSince1970]];
            documentsPath = [documentsPath URLByAppendingPathComponent:fileName];
            if (![[NSFileManager defaultManager] moveItemAtURL:location
                                                         toURL:documentsPath
                                                         error:&saveError]) {
                [self sdl_didFinishWithError:error];
            } else {
                [self sdl_didFinish];
            }
        } else if (error) {
            [self sdl_didFinishWithError:error];
        }
    }] resume];
}

- (void)sdl_didFinish {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate specFileFetchUrlDidFinish:self];
    });
}

- (void)sdl_didFinishWithError:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate specFile:self fetchUrlDidFinishWithError:error];
    });
}

@end
