//
//  RBStructViewController.h
//  RPC Builder
//

#import "RBBaseViewController.h"

@class RBStructViewController;

@protocol RBStructDelegate <NSObject>

- (void)structViewController:(RBStructViewController*)viewController didCreateStruct:(NSDictionary*)structDictionary;

@end

@class  RBStruct;

@interface RBStructViewController : RBBaseViewController

@property (strong) NSMutableDictionary* structDictionary;
@property (weak) id<RBStructDelegate> delegate;

@end
