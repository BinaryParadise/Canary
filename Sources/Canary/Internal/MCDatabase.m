//
//  MCDatabase.m
//  Canary
//
//  Created by Rake Yang on 2020/3/21.
//

#import "MCDatabase.h"
#import <fmdb/FMDB.h>

@interface MCDatabase ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end

@implementation MCDatabase

+ (instancetype)defaultDB {
    static MCDatabase *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db = [self.alloc init];
        [db config];
    });
    return db;
}

- (void)config {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject stringByAppendingString:@"/com.binaryparadise.canary"];
    NSString *fullPath = [basePath stringByAppendingString:@"/Canary.sqlite"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
        [NSFileManager.defaultManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:fullPath];
        //初始化表
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [db executeStatements:@"CREATE TABLE 'CNNetLog' ('id' INTEGER NOT NULL, 'timestamp' INTEGER NOT NULL,'method' TEXT,'url' TEXT,'requestfields' text,'responsefields' text,'requestbody' blob,'responsebody' blob,PRIMARY KEY ('id'));"];
        }];
    } else {
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:fullPath];
    }
}

- (void)executeUpdate:(NSString *)sql arguments:(nonnull NSArray *)arguments {
    [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        [db executeUpdate:sql withArgumentsInArray:arguments];
        [db close];
    }];
}


@end
