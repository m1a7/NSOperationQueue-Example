//
//  DownloadOperation.h
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, assign) NSInteger sizeFileInBytes;

- (instancetype)initWithDownloadFileName:(NSString*) fileName sizeInBytes:(NSInteger) sizeFileInBytes;


@end
