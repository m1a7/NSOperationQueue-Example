# NSOperationQueue-Example
![logo](https://raw.githubusercontent.com/m1a7/NSOperationQueue-Example/master/Documentation/logo.png)


# NSOperationQueue

[See my pdf documention on Russian language]()

Snippet of code (Work with NSOperation)
<br>
<br>


---

###  Step 1<br>
     Create subclass from NSOperation
     (*This my implementation, in practice it is possible not to add these properties)
     
```objective-c
@interface DownloadOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, assign) NSInteger sizeFileInBytes;

- (instancetype)initWithDownloadFileName:(NSString*) fileName sizeInBytes:(NSInteger) sizeFileInBytes;

@end
```

---

###  Step 2<br>
     Realize .m file for NSOperation.
     Add these methods.
     (*This my implementation, in practice it is possible not to add these properties)
     
```objective-c
@implementation DownloadOperation

#pragma mark - NSOperation private methods
- (BOOL) isConcurrent {
    return YES;
}

- (BOOL) isExecuting {
    return executing;
}

- (BOOL) isFinished {
    return finished;
}

- (void) main{
    [self setExecuting:YES setFinished:NO];
    NSInteger bytes = self.sizeFileInBytes;

    for (int i =0; i<=bytes; i++) {
     //Each time we ask, if suddenly isCanceled "to finish" the iteration and stop execution  
      if(self.isCancelled){
         return;
      }  
       NSLog(@"fileName=%@ download() = (%d/%ld) | CurrentThread = %@",self.fileName, i,(long)bytes, [NSThread currentThread]);
    }
    [self setExecuting:NO setFinished:YES];
}

- (instancetype)initWithDownloadFileName:(NSString*) fileName sizeInBytes:(NSInteger) sizeFileInBytes
{
    self = [super init];
    if (self) {
        self.fileName       = fileName;
        self.sizeFileInBytes = sizeFileInBytes;
    }
    return self;
}

- (void) setExecuting:(BOOL)isExecuting setFinished:(BOOL)isFinished{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = isExecuting;
    finished  = isFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
@end
```

---
<br>

##  (Optional) Time of experiments 👨‍💻👀✨🔥

### Snippet of Code №1
   The most basic design
 
     
```objective-c
    // Create operation
     DownloadOperation* downloadOP = [[DownloadOperation alloc] initWithDownloadFileName:@"ZoePacker.jpg" sizeInBytes:10000000];
 
     // Create queue
     NSOperationQueue* queue = [NSOperationQueue new];

     // Add the operation to the queue, thereby starting it
     [queue addOperation: downloadOP];
 
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 
         // [downloadOP cancel];        / / Ability to cancel an operation
         // [queue cancelAllOperations]; // The ability to cancel all operations in the queue
     });
```

---
<br>

### Snippet of Code №2  <br>
    Create two operations which are executed concurrently on different threads
```objective-c
    DownloadOperation* download_GermanOP = [[DownloadOperation alloc] initWithDownloadFileName:@"German.jpg" sizeInBytes:10000000];
    DownloadOperation* download_FranceOP = [[DownloadOperation alloc] initWithDownloadFileName:@"France.jpg" sizeInBytes:10000000];

    NSOperationQueue* queue = [NSOperationQueue new];
    [queue addOperation: download_GermanOP];
    [queue addOperation: download_FranceOP];
```


---
<br>

### Snippet of Code №3  <br>
    Create two operations which are executed concurrently on different threads.
     We set priorities and " quality of service"
```objective-c
     ...
    //For German
    download_GermanOP.queuePriority    = NSOperationQueuePriorityVeryHigh;  // set Priority
    download_GermanOP.qualityOfService = NSQualityOfServiceUserInteractive; // set QoS
 
    //For France
    download_GermanOP.queuePriority    = NSOperationQueuePriorityLow;       // set Priority
    download_GermanOP.qualityOfService = NSQualityOfServiceUtility;         // set QoS
    ...
```


---
<br>

### Snippet of Code №4  <br>
    Ability to set the maximum number of simultaneous operations to be performed
    This line will allow you to turn all of the "multithreaded" in "serial"
     
```objective-c
    ...
    NSOperationQueue* queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    ...
```

---
<br>

### Snippet of Code №5  <br>

  The idea is, first download all the photos in asynchronous mode, and then do the update just UI at once.
  To do this, we created an array that would be added to each download operation dependence on updateUI.

```objective-c
    ...
    NSArray<NSOperation*>* downloadingOperationArr = @[download_GermanOP,download_FranceOP];

    // The creation of our UI update operations (*implementation of this class is at the root of the project)
    UpdateUIOperation* updateUIOperation = [[UpdateUIOperation alloc] initWithDownloadFileName:@"..." processOfUpdateUI:5];

    for (NSOperation* downloadOP in downloadingOperationArr){
        [updateUIOperation addDependency:downloadOP];
    }

    NSOperationQueue* queue = [NSOperationQueue new];
    [[NSOperationQueue mainQueue] addOperation:updateUIOperation];

    for (NSOperation* downloadOP in downloadingOperationArr){
        [queue addOperation: downloadOP];
    }
```


---
<br>

### Snippet of Code №6 <br>
  This does not stop execution, but only stops adding new operations to the queue (if any :))

```objective-c
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Bzzz, stop execution !");
        [queue setSuspended:YES];
 
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"igogogo, let`s start again!");
            [queue setSuspended:NO];
        });
    });
```


---
<br>

### Snippet of Code №7 <br>
  
  Group operations as in GCD.<br>
  Philosophy:<br><br>
    1.Create an array with operations(*NSOperation).<br>
    2.Insert them into the queue(*NSOperationQueue).<br>
    3. Wait until you have completed all operation from this queue.<br>
    4. As soon as all the operations of the leading queue are completed. Start operations from the next queue 🚀🚀🚀<br>
    5. !To do this, Implement a category for nsoperationqueue.<br>
       [Category is there](https://github.com/devxoul/NSOperationQueue-CompletionBlock/tree/master/NSOperationQueue%2BCompletionBlock)
  
```objective-c
    DownloadOperation* download_GermanOP = [[DownloadOperation alloc] initWithDownloadFileName:@"German.jpg" sizeInBytes:10];
    DownloadOperation* download_FranceOP = [[DownloadOperation alloc] initWithDownloadFileName:@"France.jpg" sizeInBytes:10];
    NSArray<DownloadOperation*>* downloadingOperationArr = @[download_GermanOP,download_FranceOP];

    UpdateUIOperation* updateUI_GermanOP = [[UpdateUIOperation alloc] initWithDownloadFileName:@"German" processOfUpdateUI:5];
    UpdateUIOperation* updateUI_FranceOP = [[UpdateUIOperation alloc] initWithDownloadFileName:@"France" processOfUpdateUI:5];
    NSArray<UpdateUIOperation*>* updatingOperationArr = @[updateUI_GermanOP,updateUI_FranceOP];

    NSOperationQueue* queueDownloadGroup = [NSOperationQueue new];
    NSOperationQueue* queueUpdateUIGroup = [NSOperationQueue new];

    for (DownloadOperation* downloadOP in downloadingOperationArr){
        [queueDownloadGroup addOperation: downloadOP];
    }

    [queueDownloadGroup setCompletionBlock:^{
        NSLog(@"Downloading Queue is complete");
        // Let's start update UI queue
        for (UpdateUIOperation* updateOP in updatingOperationArr){
            [queueUpdateUIGroup addOperation:updateOP];
        }
    }];
```


