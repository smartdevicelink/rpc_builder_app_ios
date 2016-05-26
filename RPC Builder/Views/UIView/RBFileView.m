//
//  RBImageView.m
//  RPC Builder
//

#import "RBFileView.h"

#import "RBNameLabel.h"

#import "UIView+Util.h"

#import "UIAlertController+Minimal.h"

#import "RBFilePickerViewController.h"

#import <Photos/Photos.h>

@interface RBFileView () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, RBFilePickerDelegate>

@property (nonatomic, readonly) NSByteCountFormatter* byteFormatter;

@property (nonatomic, readonly) UIImage* placeholder;

@property (nonatomic, weak) UIImageView* filePreviewImageView;
@property (nonatomic, weak) UILabel* fileDescriptionLabel;

@end

@implementation RBFileView

- (instancetype)initWithTitle:(NSString*)title delegate:(id<RBParamViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectMake(kViewSpacing, 0, 0, 0)]) {
        self.userInteractionEnabled = YES;
        self.delegate = delegate;
    
        RBNameLabel* nameLabel = [[RBNameLabel alloc] initWithText:title isMandatory:YES];
        nameLabel.customDescription = @"Used for selection of local documents, either saved into sandboxed Documents or Photos Library.";
        nameLabel.delegate = self;
        [self addSubview:nameLabel];

        
        CGFloat height = 40;
        CGFloat width = 40;
        UIImageView* filePreviewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                          CGRectGetMaxY(nameLabel.frame) + kViewSpacing,
                                                                                          width,
                                                                                          height)];
        filePreviewImageView.contentMode = UIViewContentModeScaleAspectFill;
        filePreviewImageView.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor];
        filePreviewImageView.layer.borderWidth = 1.0f;
        filePreviewImageView.layer.cornerRadius = 5.0f;
        filePreviewImageView.clipsToBounds = YES;
        filePreviewImageView.image = self.placeholder;
        [self addSubview:filePreviewImageView];
        _filePreviewImageView = filePreviewImageView;
        
        UIImageView* chevronImageView = [self createChevronImageView];
        CGRect chevronImageViewFrame = chevronImageView.frame;
        chevronImageViewFrame.size.height = CGRectGetMaxY(filePreviewImageView.frame);
        chevronImageView.frame = chevronImageViewFrame;
        [self addSubview:chevronImageView];
        
        UILabel* fileDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        fileDescriptionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        fileDescriptionLabel.text = @"Select a File";
        [fileDescriptionLabel sizeToFit];
        CGRect labelFrame = fileDescriptionLabel.frame;
        CGFloat x = CGRectGetMaxX(filePreviewImageView.frame) + kViewSpacing;
        labelFrame.origin.x = x;
        labelFrame.size.width = CGRectGetMinX(chevronImageViewFrame) - kViewSpacing - x;
        fileDescriptionLabel.frame = labelFrame;
        fileDescriptionLabel.center = CGPointMake(CGRectGetMidX(fileDescriptionLabel.frame),
                                                  filePreviewImageView.center.y);
        
        [self addSubview:fileDescriptionLabel];
        _fileDescriptionLabel = fileDescriptionLabel;
    
        [self addSelfTapGestureRecognizerWithAction:@selector(presentDocumentAction:)];
        
        [self resizeToFit:[RBDeviceInformation maxViewSize]];
    }
    
    return self;
}

- (BOOL)addToDictionary:(NSMutableDictionary *)dictionary {
    // No-op
    return NO;
}

- (void)setFileData:(NSData *)fileData {
    _fileData = fileData;
    if (!fileData) {
        _fileDescriptionLabel.text = nil;
    }
}

#pragma mark - Actions
- (void)presentDocumentAction:(id)selector {
    if ([self.delegate respondsToSelector:@selector(paramView:shouldPresentViewController:)]) {

        UIAlertController* alertController = [UIAlertController actionSheetWithTitle:@"Select File From"
                                                                             message:nil];
        __weak typeof(self) weakSelf = self;
        [alertController addDefaultActionWithTitle:@"Local Storage" handler:^(UIAlertAction *action) {
            typeof(weakSelf) strongSelf = weakSelf;
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle:nil];
            RBFilePickerViewController* filePickerViewController = [storyboard instantiateViewControllerWithIdentifier:@"RBFilePickerViewController"];
            filePickerViewController.storageDirectoryPathString = @"BulkData/";
            filePickerViewController.delegate = strongSelf;
            UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:filePickerViewController];
            [strongSelf.delegate paramView:strongSelf
               shouldPresentViewController:navigationController];
        }];
        
        [alertController addDefaultActionWithTitle:@"Photos" handler:^(UIAlertAction *action) {
            typeof(weakSelf) strongSelf = weakSelf;
            UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = strongSelf;
            [strongSelf.delegate paramView:strongSelf
               shouldPresentViewController:imagePickerController];
        }];
        
        if (self.fileData) {
            [alertController addDestructiveActionWithTitle:@"Clear Selection" handler:^(UIAlertAction *action) {
                typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.fileData = nil;
                _filePreviewImageView.image = strongSelf.placeholder;
                _fileDescriptionLabel.text = @"Select a File.";
            }];
        }
    
        [alertController addCancelAction];
        
        [self.delegate paramView:self shouldPresentViewController:alertController];
    }
}

#pragma mark - Delegates
#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* image = info[UIImagePickerControllerEditedImage];
    if (!image) {
        image = info[UIImagePickerControllerOriginalImage];
    }

    self.fileData = UIImageJPEGRepresentation(image, 1.0);
    
    NSURL* assetURL = info[UIImagePickerControllerReferenceURL];
    
    if (assetURL) {
        PHFetchResult* fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
        if (fetchResult.count == 1) {
            PHAsset* asset = [fetchResult firstObject];
            PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:_filePreviewImageView.bounds.size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result) {
                         _filePreviewImageView.image = image;
                    } else {
                        _filePreviewImageView.image = self.placeholder;
                    }
                });
            }];
        }
    } else {
        _filePreviewImageView.image = self.placeholder;
    }
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

#pragma mark - RSFilePickerViewController
- (void)filePicker:(RBFilePickerViewController *)picker didSelectFileNamed:(NSString *)fileName withData:(NSData *)data {
    self.fileData = data;
    self.fileDescriptionLabel.text = [NSString stringWithFormat:@"%@ - %@", fileName, [self.byteFormatter stringFromByteCount:_fileData.length]];
    _filePreviewImageView.image = nil;
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
}

#pragma mark - Private
#pragma mark Getters
- (NSByteCountFormatter*)byteFormatter {
    static NSByteCountFormatter* byteFormatter = nil;
    if (!byteFormatter) {
        byteFormatter = [[NSByteCountFormatter alloc] init];
        byteFormatter.countStyle = NSByteCountFormatterCountStyleBinary;
    }
    return byteFormatter;
}

- (UIImage*)placeholder {
    static UIImage* placeholder = nil;
    if (!placeholder) {
        placeholder = [UIImage imageNamed:@"placeholder"];
    }
    return placeholder;
}

@end
