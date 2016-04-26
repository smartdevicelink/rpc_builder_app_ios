//
//  RPCViewController.m
//  RPC Builder
//

#import "RBFunctionViewController.h"
#import "RBFunction.h"

#import "RBFilePickerViewController.h"
#import "RBFileView.h"

@implementation RBFunctionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.navigationItem.rightBarButtonItem) {
        UIBarButtonItem* sendBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(sendAction:)];
        self.navigationItem.rightBarButtonItem = sendBarButtonItem;
    }
}

#pragma mark - Overrides
- (void)updateView {
    self.title = _function.name;

    self.requestDictionary[RBNameKey] = _function.name;
    
    [self loadParameters:_function.parameters];
    
    [self sdl_loadOptionalFunctionViews:_function];
}

#pragma mark - Actions
- (void)sendAction:(id)selector {
    [self updateRequestsDictionaryFromSubviews];

    [self.sdlManager sendRequestDictionary:self.requestDictionary
                                  bulkData:self.bulkData];
    
    if (self.navigationController.viewControllers.firstObject != self) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Private
- (void)sdl_loadOptionalFunctionViews:(RBFunction *)function {
    if (function.requiresBulkData) {
        UIView* lastView = self.scrollView.subviews.lastObject;
        
        RBFileView* fileView = [[RBFileView alloc] initWithTitle:@"bulkData"
                                                        delegate:self];
        
        CGRect newFrame = fileView.frame;
        newFrame.origin.y = kParamViewSpacing + CGRectGetMaxY(lastView.frame);
        fileView.frame = newFrame;
        
        [self.scrollView addSubview:fileView];
    }
}

@end
