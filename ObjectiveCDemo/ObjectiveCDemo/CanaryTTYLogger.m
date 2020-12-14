//
//  CanaryTTYLogger.m
//  ObjectiveCDemo
//
//  Created by Rake Yang on 2020/12/13.
//

#import "CanaryTTYLogger.h"
#import <Canary/Canary-Swift.h>

@implementation CanaryTTYLogger

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static CanaryTTYLogger *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)logMessage:(DDLogMessage *)logMessage {
    [CanarySwift.shared storeLogMessageWithDict:[logMessage dictionaryWithValuesForKeys:@{}] timestamp:logMessage.timestamp.timeIntervalSince1970];
}

@end
