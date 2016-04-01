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
    
    _localFiles = [NSMutableArray array];
            
    NSString *documentsPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsPathString = [documentsPathString stringByAppendingString:@"/BulkData/"];
    
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
    
    NSURL* documentsPathURL = [NSURL URLWithString:documentsPathString];
    
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
