//
//  SecondViewController.m
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import "SecondViewController.h"
// NSOperations
#import "DownloadOperation.h"

// Category
#import "NSOperationQueue+Completion.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UILabel *progressOfOperationLbl;

@property (strong, nonatomic) NSOperationQueue*      queueDownloading;
@property (strong, nonatomic) NSInvocationOperation* operationDownload;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.queueDownloading cancelAllOperations];

}
- (void) dealloc {
    [self.queueDownloading cancelAllOperations];
}

#pragma mark - Action

- (void) downloadingOperationMethod
{
    NSInteger bytes = 1000;
    for (int i =0; i<=bytes; i++) {
        if([self.operationDownload isCancelled]){
            return;
        }
        NSLog(@"SecondVC download() = (%d/%ld) | CurrentThread = %@", i,(long)bytes, [NSThread currentThread]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.progressOfOperationLbl.text = [NSString stringWithFormat:@"Progress: %d/%ld",i,(long)bytes];
        });
    }
   
 
}

#pragma mark - Action for Buttons
- (IBAction)startOperationAction:(id)sender {
    
    if (!self.queueDownloading && !self.operationDownload){
        self.queueDownloading  =  [NSOperationQueue new];
        self.queueDownloading.maxConcurrentOperationCount = 1;
        
        // Создание основной операции
        self.operationDownload =  [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadingOperationMethod) object:nil];
        self.operationDownload.name = @"self.operationDownload";
        self.operationDownload.completionBlock = ^{
            NSLog(@"self.operationDownload is done !\n");
        };
        [self.queueDownloading addOperation:self.operationDownload];
        
        // Создаем остальные. Для того чтобы показать эффект -setSuspend:NO
        for (int i=0; i<=4; i++) {
            NSInvocationOperation* invocationOP = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadingOperationMethod) object:nil];
            __weak NSInvocationOperation* weakOP = invocationOP;
            invocationOP.name = [NSString stringWithFormat:@"Operation#%d",i];
            invocationOP.completionBlock = ^{
                NSLog(@"%@ is done\n",weakOP.name);
            };
            [self.queueDownloading addOperation:invocationOP];
        }
        
    }
}

- (IBAction)suspendOperationAction:(id)sender {
    [self.queueDownloading setSuspended:!self.queueDownloading.suspended];
}

- (IBAction)cancelOperationAction:(id)sender {
    [self.queueDownloading cancelAllOperations];
}


@end
