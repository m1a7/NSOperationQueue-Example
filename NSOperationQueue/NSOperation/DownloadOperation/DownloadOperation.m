//
//  DownloadOperation.m
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import "DownloadOperation.h"
#import "NSOperationQueue+Completion.h"

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

- (void) main
{
    // Устанавливаем что операция начала свое выполнение
    [self setExecuting:YES setFinished:NO];
    
    NSInteger bytes = self.sizeFileInBytes;
    for (int i =0; i<=bytes; i++) {
        // Каждый раз спрашиваем, если вдруг isCanceled то "дозавершаем" итерацию и прекращаем выполнение
        if(self.isCancelled){
            return;
        }
        if (!self.isExecuting){
            NSLog(@"На паузе!");
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
