//
//  RBBaseTableViewCell.m
//  RPC Builder
//

#import "RBBaseTableViewCell.h"

@implementation RBBaseTableViewCell

- (void)updateWithObject:(id)object {
    [self doesNotRecognizeSelector:_cmd];
}

+ (NSString*)cellIdentifier {
    return NSStringFromClass(self.class);
}

@end
