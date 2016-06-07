//
//  NSString+Regex.h
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 6/7/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Regex)

- (NSString*)firstStringMatchUsingRegex:(NSRegularExpression*)regex;

@end
