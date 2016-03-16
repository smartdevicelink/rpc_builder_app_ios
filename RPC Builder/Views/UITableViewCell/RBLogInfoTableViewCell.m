//
//  RBLogInfoTableViewCell.m
//  RPC Builder
//

#import "RBLogInfoTableViewCell.h"
#import "RBLogInfo.h"

@interface RBLogInfoTableViewCell ()

@property (nonatomic, weak, readonly) UIView* notificationTypeView;

@end

@implementation RBLogInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:self.textLabel.font.pointSize];
        
        CGRect notificationViewFrame = CGRectMake(0,
                                                  0,
                                                  10,
                                                  CGRectGetHeight(self.contentView.bounds));
        UIView* notificationTypeView = [[UIView alloc] initWithFrame:notificationViewFrame];
        [self.contentView addSubview:notificationTypeView];
        _notificationTypeView = notificationTypeView;
    }
    return self;
}

- (void)updateWithObject:(id)object {
    RBLogInfo* logInfo = (RBLogInfo*)object;
    self.textLabel.text = logInfo.title;
    self.detailTextLabel.text = logInfo.dateString;
    self.notificationTypeView.backgroundColor = logInfo.color;
}

@end
