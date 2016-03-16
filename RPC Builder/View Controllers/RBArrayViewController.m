//
//  RBArrayViewController.m
//  RPC Builder
//

#import "RBArrayViewController.h"
#import "RBStructViewController.h"

#import "RBDeviceInformation.h"

#import "RBParser.h"

#import "RBElementTextField.h"

@interface RBArrayViewController () <UITableViewDataSource, UITableViewDelegate, RBStructDelegate>

@property (nonatomic, readonly) UIBarButtonItem* addBarButton;

@end

@implementation RBArrayViewController {
    IBOutlet UITableView* _tableView;
    IBOutlet RBElementTextField* _createParamTextField;

    NSMutableArray* _mutableContents;
    NSMutableArray* _cellTitleArray;
    
    BOOL _displayCreateCell;
}

@synthesize addBarButton = _addBarButton;

- (void)updateView {
    
    self.title = self.parameterName;
    self.navigationItem.rightBarButtonItem = self.addBarButton;
    
    _cellTitleArray = [NSMutableArray array];
    
    if (self.parametersDictionary[self.parameterName]) {
        _mutableContents = [self.parametersDictionary[self.parameterName] mutableCopy];
        if ([[RBParser sharedParser] structOfType:self.paramType]) {
            for (NSDictionary* objectDict in _mutableContents) {
                [_cellTitleArray addObject:[self sdl_titleForObjectDictionary:objectDict]];
            }
        } else {
            _cellTitleArray = [NSMutableArray arrayWithArray:_mutableContents];
        }
    } else {
        _mutableContents = [NSMutableArray array];
        self.parametersDictionary[self.parameterName] = _mutableContents;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.isMovingFromParentViewController) {
        self.parametersDictionary[self.parameterName] = [_mutableContents copy];
        [_delegate arrayViewControllerWillDismiss:self
                                        withCount:_mutableContents.count];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Actions
- (void)addAction:(id)selector {
    if (self.structObj) {
        RBStructViewController* viewController = [[RBStructViewController alloc] initWithNibName:@"RBBaseViewController"
                                                                                          bundle:nil];
        viewController.delegate = self;
        viewController.param = self.param;
        viewController.structObj = self.structObj;
        [self.navigationController pushViewController:viewController
                                             animated:YES];
    } else {
        UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(cancelAction:)];
        UIBarButtonItem* saveBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveAction:)];
        self.navigationItem.leftBarButtonItem = cancelBarButton;
        self.navigationItem.rightBarButtonItem = saveBarButtonItem;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        RBEnum* enumObj = [[RBParser sharedParser] enumOfType:self.paramType];
        [UIView animateWithDuration:0.3 animations:^{
            _tableView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            if (enumObj) {
                _createParamTextField.elements = enumObj.elements;
                _createParamTextField.inputView = self.pickerView;
                _createParamTextField.inputAccessoryView = self.doneToolbar;
            }
            [_createParamTextField becomeFirstResponder];
        }];
    }
}

- (void)cancelAction:(id)selector {
    [_createParamTextField resignFirstResponder];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.addBarButton;
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _createParamTextField.text = nil;
    }];
}

- (void)saveAction:(id)selector {
    [_createParamTextField resignFirstResponder];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.addBarButton;
    [_mutableContents addObject:_createParamTextField.text];
    [_cellTitleArray addObject:_createParamTextField.text.length ? _createParamTextField.text : @"Empty String"];
    [_tableView reloadData];
    [UIView animateWithDuration:0.3 animations:^{
        _tableView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        _createParamTextField.text = nil;
    }];
}

#pragma mark - Getters
- (UIBarButtonItem*)addBarButton {
    if (!_addBarButton) {
        _addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                      target:self
                                                                      action:@selector(addAction:)];
    }
    return _addBarButton;
}

#pragma mark - Delegates
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mutableContents.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark UITableViewDelegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ItemTableViewCell"];
    NSString* title = _cellTitleArray[indexPath.row];
    cell.textLabel.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_mutableContents removeObjectAtIndex:indexPath.row];
        [_cellTitleArray removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:indexPath.row
                                                                 inSection:(_displayCreateCell ? 1 : 0)]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    
    self.navigationItem.rightBarButtonItem.enabled = (newString.length > 0);
    return YES;
}

#pragma mark RBStructDelegate
- (void)structViewController:(RBStructViewController *)viewController didCreateStruct:(NSDictionary *)structDictionary {
    [self.navigationController popViewControllerAnimated:YES];
    [_mutableContents addObject:structDictionary];
    [_cellTitleArray addObject:[self sdl_titleForObjectDictionary:structDictionary]];
    
    [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_mutableContents.count - 1
                                                            inSection:(_displayCreateCell ? 1 : 0)]]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private Helpers
- (NSString*)sdl_titleForObjectDictionary:(NSDictionary*)objectDictionary {
    NSArray* alphabeticKeys = [objectDictionary.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSUInteger index = 0;
    NSMutableString* mutableTitle = [NSMutableString string];
    for (NSString* key in alphabeticKeys) {
        [mutableTitle appendFormat:@"%@: %@", key, objectDictionary[key]];
        if (index < (alphabeticKeys.count - 1)) {
            [mutableTitle appendString:@", "];
            index++;
        }
    }
    return [mutableTitle copy];
}

@end
