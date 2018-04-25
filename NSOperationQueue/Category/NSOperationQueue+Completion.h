//
//  NSOperationQueue+Completion.h
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double NSOperationQueue_CompletionBlockVersionNumber;
FOUNDATION_EXPORT const unsigned char NSOperationQueue_CompletionBlockVersionString[];

typedef void (^NSOperationQueueCompletionBlock)(void);

@interface NSOperationQueue (CompletionBlock)
@property (nonatomic, strong, nullable) NSOperationQueueCompletionBlock completionBlock;
@end
