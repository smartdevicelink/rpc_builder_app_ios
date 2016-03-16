//
//  RBBaseViewController.h
//  RPC Builder
//

#import "RBScrollViewController.h"
#import "RBParamView.h"

#import "RBSettingsManager.h"
#import "SDLManager.h"

static const CGFloat kParamViewSpacing = 20.0f;

@interface RBBaseViewController : RBScrollViewController <RBParamViewDelegate, UITextFieldDelegate>

@property (nonatomic, readonly) RBSettingsManager* settingsManager;
@property (nonatomic, readonly) SDLManager* sdlManager;

@property (nonatomic, readonly) UIPickerView* pickerView;
@property (nonatomic, readonly) UIToolbar* doneToolbar;

@property (nonatomic, strong) NSMutableDictionary* requestDictionary;
@property (nonatomic, strong) NSMutableDictionary* parametersDictionary;

@property (nonatomic, readonly) NSString* parameterName;
@property (nonatomic, readonly) NSString* paramType;

@property (nonatomic, strong) NSData* bulkData;

@property (weak) RBParam* param;
@property (strong) RBStruct* structObj;
@property (strong) RBEnum* enumObj;

- (void)updateView;

- (void)updateRequestsDictionaryFromSubviews;

- (void)loadParameters:(NSArray*)parameters;

@end
