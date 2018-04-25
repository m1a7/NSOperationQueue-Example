//
//  UpdateUIOperation.m
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import "UpdateUIOperation.h"

@implementation UpdateUIOperation

- (void) main
{
    // Устанавливаем что операция начала свое выполнение
    [self setExecuting:YES setFinished:NO];
    NSInteger bytes = self.processOfUpdateUI;
    for (int i =0; i<=bytes; i++) {
        // Каждый раз спрашиваем, если вдруг isCanceled то "дозавершаем" итерацию и прекращаем выполнение
        if(self.isCancelled){
            return;
        }
        NSLog(@"fileName=%@ updateUI() = (%d/%ld) | CurrentThread = %@",self.fileName, i,(long)bytes, [NSThread currentThread]);
    }
    [self setExecuting:NO setFinished:YES];
}


#pragma mark - init

- (instancetype)initWithDownloadFileName:(NSString*) fileName processOfUpdateUI:(NSInteger) processOfUpdateUI
{
    self = [super init];
    if (self) {
        self.fileName          = fileName;
        self.processOfUpdateUI = processOfUpdateUI;
    }
    return self;
}


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


#pragma mark - Helpers

- (void) setExecuting:(BOOL)isExecuting setFinished:(BOOL)isFinished{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = isExecuting;
    finished  = isFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


@end
