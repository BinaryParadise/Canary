//
//  MCDatabase.h
//  Canary
//
//  Created by Rake Yang on 2020/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCDatabase : NSObject

+ (instancetype)defaultDB;

- (void)executeUpdate:(NSString *)sql arguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
