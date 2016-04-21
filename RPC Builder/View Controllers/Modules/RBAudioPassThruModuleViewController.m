//
//  RBAudioPassThruModuleViewController.m
//  RPC Builder
//
//  Created by Muller, Alexander (A.) on 4/18/16.
//  Copyright © 2016 Ford Motor Company. All rights reserved.
//

#import "RBAudioPassThruModuleViewController.h"
#import "RBFunctionsViewController.h"
#import "RBParser.h"

@interface RBAudioPassThruModuleViewController ()

@property (nonatomic, weak) RBFunctionViewController* viewController;

@property (nonatomic, weak) IBOutlet UILabel* samplingRateLabel;
@property (nonatomic, weak) IBOutlet UILabel* recordingDurationLabel;

@end

@implementation RBAudioPassThruModuleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewController) {
        RBFunction* performAudioPassThru = [[RBParser sharedParser] functionOfType:@"PerformAudioPassThru"];
        self.viewController = [RBFunctionsViewController viewControllerForFunction:performAudioPassThru];
    }
}

#pragma mark - Overrides
+ (NSString*)moduleTitle {
    return @"Audio Pass Through";
}

+ (NSString*)moduleDescription {
    return @"Allows for testing audio pass through capabilities.";
}

+ (NSString*)moduleImageName {
    return @"AudioPassThru";
}

#pragma mark - Actions
- (IBAction)editPerformAudioPassthroughAction:(id)sender {
    [self.navigationController pushViewController:self.viewController
                                         animated:YES];
}

- (IBAction)sendPerformAudioPassthroughAction:(id)sender {
    [[SDLManager sharedManager] sendRequestDictionary:self.viewController.requestDictionary
                                             bulkData:nil];
}

@end
