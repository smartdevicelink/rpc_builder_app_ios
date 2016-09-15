//
//  RBParser.m
//  RPC Builder
//

#import "RBParser.h"

static NSString* const RBDescriptionKey = @"description";
static NSString* const RBDesignDescriptionKey = @"designdescription";
static NSString* const RBElementKey = @"element";
static NSString* const RBEnumKey = @"enum";
static NSString* const RBFunctionKey = @"function";
static NSString* const RBInterfaceKey = @"interface";
static NSString* const RBIssueKey = @"issue";
static NSString* const RBParamKey = @"param";
static NSString* const RBStructKey = @"struct";
static NSString* const RBTodoKey = @"todo";
static NSString* const RBRequestKey = @"request";
static NSString* const RBResponseKey = @"response";

NSString* const RBParserErrorStringURLNotFound = @"The URL provided was not found.";

typedef void (^RBURLSuccessCompletionHandler)(void);

@interface RBParser () <NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser* xmlParser;

@property (nonatomic, strong) NSURL* remoteURL;

@property (nonatomic, strong) NSMutableArray* tagsContainer;
@property (nonatomic, strong) NSMutableDictionary* enumsDictionary;
@property (nonatomic, strong) NSMutableDictionary* structsDictionary;

@property (nonatomic, strong) NSMutableArray* requestsContainer;
@property (nonatomic, strong) NSMutableArray* responsesContainer;
@property (nonatomic, strong) NSMutableArray* functionsContainer;
@property (nonatomic, strong) NSMutableArray* elementsContainer;

@property (nonatomic, strong) NSString* currentTag;

@property (copy) RBURLSuccessCompletionHandler successHandler;

@end

@implementation RBParser

+ (instancetype)sharedParser {
    static RBParser* sharedParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParser = [[RBParser alloc] init];
    });
    
    return sharedParser;
}

- (instancetype)init {
    if (self = [super init]) {
        [self sdl_resetContainers];
    }
    return self;
}

#pragma mark - Public Functions
- (void)parseSpecAtURL:(NSURL*)specURL delegate:(id<RBParserDelegate>)delegate {
    if (![specURL isEqual:_remoteURL]) {
        _error = nil;
        __weak typeof(self) weakSelf = self;
        [self sdl_validateURLExistence:specURL withSuccessHandler:^{
            typeof(weakSelf) strongSelf = weakSelf;
            _delegate = delegate;
            _remoteURL = specURL;
            [strongSelf sdl_resetContainers];
            _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:specURL];
            _xmlParser.delegate = strongSelf;
            
            if (![_xmlParser parse]) {
                [strongSelf sdl_parserErrorOccurred:_xmlParser.parserError];
            }
        }];
    } else {
        [self sdl_parserDidFinish];
    }
}

- (void)parseSpecData:(NSData*)data delegate:(id<RBParserDelegate>)delegate {
    _delegate = delegate;
    [self sdl_resetContainers];
    _xmlParser = [[NSXMLParser alloc] initWithData:data];
    _xmlParser.delegate = self;
    
    if (![_xmlParser parse]) {
        [self sdl_parserErrorOccurred:_xmlParser.parserError];
    }
}

- (RBStruct*)structOfType:(NSString*)type {
    return _structsDictionary[type];
}

- (RBEnum*)enumOfType:(NSString *)type {
    return _enumsDictionary[type];
}

- (RBFunction*)functionOfType:(NSString*)type {
    RBFunction* function = nil;
    for (RBFunction* func in _requestsContainer) {
        if ([func.name isEqualToString:type]) {
            function = func;
            break;
        }
    }
    return function;
}

#pragma mark - Getters
- (NSArray*)RPCs {
    return [_requestsContainer copy];
}

- (NSArray*)functions {
    return [_functionsContainer copy];
}

- (NSArray*)elements {
    return [_elementsContainer copy];
}

#pragma mark - Delegates
#pragma mark NSXMLParser
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    _currentTag = elementName;
    if ([elementName isEqualToString:RBInterfaceKey]
        || [elementName isEqualToString:RBDescriptionKey]
        || [elementName isEqualToString:RBDesignDescriptionKey]
        || [elementName isEqualToString:RBIssueKey]
        || [elementName isEqualToString:RBTodoKey]) {
        return; // no-op
    } else if ([elementName isEqualToString:RBEnumKey]) {
        [_tagsContainer addObject:[RBEnum objectWithDictionary:attributeDict]];
    } else if ([elementName isEqualToString:RBElementKey]) {
        [_tagsContainer addObject:[RBElement objectWithDictionary:attributeDict]];
    } else if ([elementName isEqualToString:RBStructKey]) {
        [_tagsContainer addObject:[RBStruct objectWithDictionary:attributeDict]];
    } else if ([elementName isEqualToString:RBParamKey]) {
        [_tagsContainer addObject:[RBParam objectWithDictionary:attributeDict]];
    } else if ([elementName isEqualToString:RBFunctionKey]) {
        [_tagsContainer addObject:[RBFunction objectWithDictionary:attributeDict]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:RBInterfaceKey]
        || [elementName isEqualToString:RBIssueKey]
        || [elementName isEqualToString:RBTodoKey]) {
        return; // no-op
    }
    
    _currentTag = nil;
    
    id lastObject = [_tagsContainer lastObject];
    [_tagsContainer removeLastObject];
    if ([elementName isEqualToString:RBEnumKey]) {
        _enumsDictionary[[lastObject name]] = lastObject;
        return;
    } else if ([elementName isEqualToString:RBFunctionKey]) {
        if ([[lastObject messageType] isEqualToString:RBRequestKey]) {
            [_requestsContainer addObject:lastObject];
        } else if ([[lastObject messageType] isEqualToString:RBResponseKey]) {
            [_responsesContainer addObject:lastObject];
        }
        [_functionsContainer addObject:lastObject];
    } else if ([elementName isEqualToString:RBStructKey]) {
        _structsDictionary[[lastObject name]] = lastObject;
    } else if ([elementName isEqualToString:RBElementKey]) {
        [_elementsContainer addObject:lastObject];
    }

    [self sdl_addObject:lastObject
      toParentObject:[_tagsContainer lastObject]];
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([_currentTag isEqualToString:RBIssueKey]
        || [_currentTag isEqualToString:RBTodoKey]) {
        return; // no-op
    }
    NSString* newString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (newString.length) {
        [_tagsContainer addObject:newString];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    [self sdl_parserErrorOccurred:parseError];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [self sdl_parserDidFinish];
}

#pragma mark - Private Helpers
- (void)sdl_resetContainers {
    _tagsContainer = [NSMutableArray array];
    _enumsDictionary = [NSMutableDictionary dictionary];
    _structsDictionary = [NSMutableDictionary dictionary];
    
    _requestsContainer = [NSMutableArray array];
    _responsesContainer = [NSMutableArray array];
    _functionsContainer = [NSMutableArray array];
    _elementsContainer = [NSMutableArray array];
}

- (void)sdl_addObject:(id)object toParentObject:(id)parentObject {
    if ([object isKindOfClass:[NSString class]]) {
        if ([parentObject isKindOfClass:[NSString class]]) {
            [_tagsContainer removeObject:parentObject];
            NSString* newString = [parentObject stringByAppendingString:object];
            [self sdl_addObject:newString
              toParentObject:[_tagsContainer lastObject]];
        } else if ([parentObject isKindOfClass:[RBElement class]]) {
            [parentObject appendDescription:object];
        } else if ([parentObject isKindOfClass:[RBEnum class]]) {
            [parentObject appendDescription:object];
        }
    } else if ([object isKindOfClass:[RBElement class]]) {
        if ([parentObject isKindOfClass:[RBEnum class]]) {
            [parentObject addElement:object];
        } else if ([parentObject isKindOfClass:[RBParam class]]) {
            [parentObject addElement:object];
        }
    } else if ([object isKindOfClass:[RBParam class]]) {
        if ([parentObject isKindOfClass:[RBStruct class]]
            || [parentObject isKindOfClass:[RBFunction class]]) {
            [parentObject addParameter:object];
        }
    }
}

- (void)sdl_parserDidFinish {
    _error = nil;
    if ([self.delegate respondsToSelector:@selector(parserDidFinish:)]) {
        [self.delegate parserDidFinish:self];
    }
}

- (void)sdl_parserErrorOccurred:(NSError*)error {
    _error = error;
    if ([_delegate respondsToSelector:@selector(parserErrorOccurred:)]) {
        NSString* errorString = nil;
        switch (error.code) {
            case NSXMLParserAttributeHasNoValueError:
                errorString = @"No XML found at URL.";
                break;
                
            default:
                break;
        }
        if (errorString) {
            _error = [NSError errorWithDomain:error.domain
                                         code:error.code
                                     userInfo:@{NSLocalizedDescriptionKey : errorString}];
        }
        [_delegate parserErrorOccurred:self];
    }
}

- (void)sdl_validateURLExistence:(NSURL*)url withSuccessHandler:(RBURLSuccessCompletionHandler)handler {
    _successHandler = handler;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"HEAD";
    
    __weak typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        if (httpResponse.statusCode == 200) {
            if (_successHandler) {
                _successHandler();
            }
        } else {
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf sdl_handleErrorForHTTPStatusCode:httpResponse.statusCode];
        }
    }] resume];
}

- (void)sdl_handleErrorForHTTPStatusCode:(NSInteger)statusCode {
    NSString* errorString = nil;
    switch (statusCode) {
        case RBParserErrorURLNotFound:
            errorString = RBParserErrorStringURLNotFound;
            break;
        default:
            errorString = @"Unknown Error";
            break;
    }
    NSError* error = [NSError errorWithDomain:@"RBParserError"
                                         code:statusCode
                                     userInfo:@{
                                                NSLocalizedDescriptionKey : errorString
                                                }];
    [self sdl_parserErrorOccurred:error];
}

@end
