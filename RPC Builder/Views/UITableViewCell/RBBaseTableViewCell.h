//
//  RBBaseTableViewCell.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

@interface RBBaseTableViewCell : UITableViewCell

- (void)updateWithObject:(id)object;

+ (NSString*)cellIdentifier;

@end
