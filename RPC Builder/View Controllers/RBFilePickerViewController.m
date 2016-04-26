//
//  RBImagePickerController.m
//  RPC Builder
//

#import "RBFilePickerViewController.h"

#import "NSFileWrapper+Extensions.h"

@interface RBFilePickerViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* localFiles;

@end

@implementation RBFilePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFilesInStoragePath];
}

#pragma mark - Public
- (void)loadFilesInStoragePath {
    _localFiles = [NSMutableArray array];

    if (!self.fullStoragePathString) {
        NSString *documentsPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        if (self.storageDirectoryPathString) {
            if ([self.storageDirectoryPathString characterAtIndex:0] != '/') {
                _storageDirectoryPathString = [NSString stringWithFormat:@"/%@", self.storageDirectoryPathString];
            }
            documentsPathString = [documentsPathString stringByAppendingString:self.storageDirectoryPathString];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPathString]) {
            NSError* error = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:documentsPathString
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&error];
            if (error) {
                NSLog(@"Error creating directory: %@", error);
            }
        }
        
        _fullStoragePathString = documentsPathString;
    }
    
    NSURL* documentsPathURL = [NSURL URLWithString:self.fullStoragePathString];
    
    NSArray* fileProperties = @[
                                NSURLLocalizedNameKey,
                                NSURLIsDirectoryKey,
                                NSURLTotalFileSizeKey
                                ];
    
    NSEnumerator* filesEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:documentsPathURL
                                                         includingPropertiesForKeys:fileProperties
                                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       errorHandler:nil];
    
    for (NSURL* fileURL in filesEnumerator) {
        NSFileWrapper* fileWrapper = [[NSFileWrapper alloc] initWithURL:fileURL
                                                                options:NSFileWrapperReadingImmediate
                                                                  error:nil];
        if (!fileWrapper.isDirectory) {
            [_localFiles addObject:fileWrapper];
        }
    }
}

- (BOOL)saveData:(NSData *)data withFileName:(NSString *)fileName {
    NSString* fullFilePath = [self.fullStoragePathString stringByAppendingPathComponent:fileName];
    BOOL successful = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
        successful = [data writeToFile:fullFilePath
                            atomically:NO];
        [self loadFilesInStoragePath];
    } else {
        NSLog(@"File exists at %@", fileName);
    }
    return successful;
}

#pragma mark - Setters
- (void)setStorageDirectoryPathString:(NSString *)storageDirectoryPathString {
    _storageDirectoryPathString = storageDirectoryPathString;
    [self loadFilesInStoragePath];
}

#pragma mark - Actions
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - Delegates
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(filePicker:didSelectFileNamed:withData:)]) {
        NSFileWrapper* fileWrapper = _localFiles[indexPath.row];
        [_delegate filePicker:self didSelectFileNamed:fileWrapper.preferredFilename withData:fileWrapper.regularFileContents];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Data Source
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _localFiles.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RBFileTableViewCell"];

    NSFileWrapper* fileWrapper = _localFiles[indexPath.row];
    
    cell.textLabel.text = fileWrapper.preferredFilename;
    cell.detailTextLabel.text = fileWrapper.fileSizeString;
    
    return cell;
}

@end
