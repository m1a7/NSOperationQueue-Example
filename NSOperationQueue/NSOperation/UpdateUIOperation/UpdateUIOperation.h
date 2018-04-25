//
//  UpdateUIOperation.h
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateUIOperation : NSOperation{
    BOOL executing;
    BOOL finished;
}

@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, assign) NSInteger processOfUpdateUI; // set any number

- (instancetype)initWithDownloadFileName:(NSString*) fileName processOfUpdateUI:(NSInteger) processOfUpdateUI;

@end
