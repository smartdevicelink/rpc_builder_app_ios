//
//  RBImagePickerController.h
//  RPC Builder
//

#import <UIKit/UIKit.h>

@class RBFilePickerViewController;

@protocol RBFilePickerDelegate <NSObject>

@optional
- (void)filePicker:(RBFilePickerViewController*)picker didSelectFileNamed:(NSString*)fileName withData:(NSData*)data;

@end


@interface RBFilePickerViewController : UIViewController

@property (weak) id<RBFilePickerDelegate> delegate;

@property (nonatomic, strong) NSString* storageDirectoryPathString;
@property (nonatomic, strong, readonly) NSString* fullStoragePathString;

- (void)loadFilesInStoragePath;

- (BOOL)saveData:(NSData*)data withFileName:(NSString*)fileName;

@end
