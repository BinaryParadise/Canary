//
//  MCLoggerUtils.m
//  MCLogger
//
//  Created by Rake Yang on 2019/2/19.
//  Copyright © 2019 BinaryParadise. All rights reserved.
//

#import "MCLoggerUtils.h"
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#define kLoggerServiceName  @"MCIdentifierForVendor"
#define kBundleIdentifier   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]

@implementation MCLoggerUtils

+ (NSString *)systemName {
#if TARGET_OS_OSX
    return @"macOS";
#else
    return [UIDevice currentDevice].systemName;
#endif
}

@end
