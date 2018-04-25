//
//  AppDelegate.m
//  NSOperationQueue
//
//  Created by Uber on 25/04/2018.
//  Copyright © 2018 uber. All rights reserved.
//

#import "AppDelegate.h"
// NSOperations
#import "DownloadOperation.h"
#import "UpdateUIOperation.h"

// Category
#import "NSOperationQueue+Completion.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    return YES;
}



/*
  ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
  //
  //  Самая простая конструкция
  //
  ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 
 
     // Создаем операцию
     DownloadOperation* downloadOP = [[DownloadOperation alloc] initWithDownloadFileName:@"ZoePacker.jpg" sizeInBytes:10000000];
 
     // Создаем очередь
     NSOperationQueue* queue = [NSOperationQueue new];

     // Добавляем операцию в очередь тем самым запуская ее
     [queue addOperation: downloadOP];
 
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 
         // [downloadOP cancel];         // Возможность отмены операции
         // [queue cancelAllOperations]; // Возможность отмены всех операций в очереди
     });
 
 
  ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
*/



/*
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 //
 // Создаем сразу две операции которые выполняются одновременно в разных потоках
 //
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 
    DownloadOperation* download_GermanOP = [[DownloadOperation alloc] initWithDownloadFileName:@"German.jpg" sizeInBytes:10000000];
    DownloadOperation* download_FranceOP = [[DownloadOperation alloc] initWithDownloadFileName:@"France.jpg" sizeInBytes:10000000];

    NSOperationQueue* queue = [NSOperationQueue new];
    [queue addOperation: download_GermanOP];
    [queue addOperation: download_FranceOP];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  [queue cancelAllOperations];  // Отмена всех операций
    });

///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
*/


/*
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 //
 // Создаем сразу две операции которые выполняются одновременно в разных потоках.
 // Задаем приоритеты и "качество сервиса"
 //
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
    ...
    // Для Германии
    download_GermanOP.queuePriority    = NSOperationQueuePriorityVeryHigh;  // Задача приоритета
    download_GermanOP.qualityOfService = NSQualityOfServiceUserInteractive; // Задача QoS
 
    // Для Франции
    download_GermanOP.queuePriority    = NSOperationQueuePriorityLow;       // Задача приоритета
    download_GermanOP.qualityOfService = NSQualityOfServiceUtility;         // Задача QoS
    ...
///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
*/


/*
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
    ...
    NSOperationQueue* queue = [NSOperationQueue new];
    // Возможность задать максимальное колличество выполняемых единовременно операций
    // Данная строчка позволит превратить очередь из "многопоточной" в "последовательную"
    queue.maxConcurrentOperationCount = 1;
    ...
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
*/



/*
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////

    // Идея такова, сначала загружаем все фото в асинхронном режиме, а потом занимаемся апдейтом всего UI сразу
    // Для этого создали массив что-бы к каждой операции скачивания была добавлена зависимость от updateUI
 
    NSArray<NSOperation*>* downloadingOperationArr = @[download_GermanOP,download_FranceOP];

    // Создание нашей update UI операции
    UpdateUIOperation* updateUIOperation = [[UpdateUIOperation alloc] initWithDownloadFileName:@"..." processOfUpdateUI:5];

    for (NSOperation* downloadOP in downloadingOperationArr){
        [updateUIOperation addDependency:downloadOP];
    }

    NSOperationQueue* queue = [NSOperationQueue new];
    [[NSOperationQueue mainQueue] addOperation:updateUIOperation];

    for (NSOperation* downloadOP in downloadingOperationArr){
        [queue addOperation: downloadOP];
    }

 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
*/


    
/*
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 
    Это не остановит выполнение, а только лишь прекратит добавлять новые операции в очередь (если они есть :))
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"Бззз стоп, выполнение!");
        [queue setSuspended:YES];
 
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"Игого, погнали снова!");
            [queue setSuspended:NO];
        });
    });

 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 */


/*
///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////

    // Группы операций
    // 1. Сначала скачиваем и дожидаемся конца всех операций
    // 2. Апдейтим UI
 
    DownloadOperation* download_GermanOP = [[DownloadOperation alloc] initWithDownloadFileName:@"German.jpg" sizeInBytes:10];
    DownloadOperation* download_FranceOP = [[DownloadOperation alloc] initWithDownloadFileName:@"France.jpg" sizeInBytes:10];
    NSArray<DownloadOperation*>* downloadingOperationArr = @[download_GermanOP,download_FranceOP];

    NSOperationQueue* queueDownloadGroup = [NSOperationQueue new];
    NSOperationQueue* queueUpdateUIGroup = [NSOperationQueue new];

    for (DownloadOperation* downloadOP in downloadingOperationArr){
        [queueDownloadGroup addOperation: downloadOP];
    }

    [queueDownloadGroup setCompletionBlock:^{
        // Как только все скачается.
        // Начнем операции на updateUI
        NSLog(@"Queue is complete");
        
        for (DownloadOperation* downloadOP in downloadingOperationArr){
            UpdateUIOperation* updateUIOperation = [[UpdateUIOperation alloc] initWithDownloadFileName:downloadOP.fileName processOfUpdateUI:5];
            [queueUpdateUIGroup addOperation:updateUIOperation];
        }
    }];

 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
 */




/*
 ///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////

    // Операции на скачивание
    DownloadOperation* download_GermanOP = [[DownloadOperation alloc] initWithDownloadFileName:@"German.jpg" sizeInBytes:10];
    DownloadOperation* download_FranceOP = [[DownloadOperation alloc] initWithDownloadFileName:@"France.jpg" sizeInBytes:10];
    NSArray<DownloadOperation*>* downloadingOperationArr = @[download_GermanOP,download_FranceOP];

    // Операции на обновления UI
    UpdateUIOperation* updateUI_GermanOP = [[UpdateUIOperation alloc] initWithDownloadFileName:@"German" processOfUpdateUI:5];
    UpdateUIOperation* updateUI_FranceOP = [[UpdateUIOperation alloc] initWithDownloadFileName:@"France" processOfUpdateUI:5];
    NSArray<UpdateUIOperation*>* updatingOperationArr = @[updateUI_GermanOP,updateUI_FranceOP];

    // Создание отдельных очердей
    NSOperationQueue* queueDownloadGroup = [NSOperationQueue new];
    NSOperationQueue* queueUpdateUIGroup = [NSOperationQueue new];

    for (DownloadOperation* downloadOP in downloadingOperationArr){
        [queueDownloadGroup addOperation: downloadOP];
    }

    [queueDownloadGroup setCompletionBlock:^{
        // Как только закончиться первая группа операций.
        // Начнем операции на updateUI
        NSLog(@"Queue is complete");
        for (UpdateUIOperation* updateOP in updatingOperationArr){
            [queueUpdateUIGroup addOperation:updateOP];
        }
    }];

///////////////////////////// ///////////////////////////// ///////////////////////////// /////////////////////////////
*/

@end
