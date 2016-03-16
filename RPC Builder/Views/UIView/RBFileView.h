//
//  RBImageView.h
//  RPC Builder
//

#import "RBParamView.h"

@interface RBFileView : RBParamView

- (instancetype)initWithTitle:(NSString*)title delegate:(id<RBParamViewDelegate>)delegate;

@property (nonatomic, strong, readonly) NSData* fileData;

@end
