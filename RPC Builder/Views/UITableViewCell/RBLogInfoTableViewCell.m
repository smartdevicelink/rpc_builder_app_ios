//
//  RBLogInfoTableViewCell.m
//  RPC Builder
//

#import "RBLogInfoTableViewCell.h"
#import "RBLogInfo.h"

@interface RBLogInfoTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UILabel* accessoryLabel;
@property (nonatomic, weak) IBOutlet UIView* notificationTypeView;

@end

@implementation RBLogInfoTableViewCell

- (void)updateWithObject:(id)object {
    RBLogInfo* logInfo = (RBLogInfo*)object;
    self.titleLabel.text = logInfo.title;
    self.accessoryLabel.attributedText = [self sdl_attributedStringForDateString:logInfo.dateString
                                                                 andResultString:logInfo.resultString
                                                                       withColor:logInfo.resultColor];
    self.notificationTypeView.backgroundColor = logInfo.typeColor;
}

- (NSAttributedString*)sdl_attributedStringForDateString:(NSString*)dateString andResultString:(NSString*)resultString withColor:(UIColor*)resultColor {
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:dateString];
    if (resultString.length) {
        NSDictionary* attributes = @{NSForegroundColorAttributeName : resultColor,
                                     NSFontAttributeName : [UIFont boldSystemFontOfSize:self.accessoryLabel.font.pointSize]};
        NSMutableAttributedString* resultAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" - %@", resultString]];
        [resultAttributedString addAttributes:attributes range:NSMakeRange(3, resultString.length)];
        [attributedString appendAttributedString:resultAttributedString];
    }
    return attributedString;
}

@end
