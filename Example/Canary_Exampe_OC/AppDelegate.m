//
//  AppDelegate.m
//  Canary_Exampe_OC
//
//  Created by Rake Yang on 2020/3/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "AppDelegate.h"

@import Canary;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CanaryManager.manager.appKey = @"com.binaryparadise.neverland";
    CanaryManager.manager.enableDebug = YES;
    CanaryManager.manager.baseURL = [NSURL URLWithString:@"https://y.neverland.life"];
    CanaryManager.manager.currentName = @"奶味蓝";
    [CanaryManager.manager startLogMonitor:^NSDictionary<NSString *, id> *{
        return @{@"PushToken": @"fjejfliejglaje",
                 @"uid": @"0101010101",
                 @"num": @100982,
                 @"dict": @{@"a":@"neverland", @"b":@"life", @"n": @1988788978639}
                };
    }];
    return YES;
}

@end
