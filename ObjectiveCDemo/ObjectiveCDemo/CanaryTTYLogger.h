//
//  CanaryTTYLogger.h
//  ObjectiveCDemo
//
//  Created by Rake Yang on 2020/12/13.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface CanaryTTYLogger : DDAbstractLogger

+ (instancetype)shared;

@end

NS_ASSUME_NONNULL_END
