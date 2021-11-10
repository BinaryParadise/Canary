//
//  AppDelegate.m
//  CanaryDemo
//
//  Created by Rake Yang on 2020/12/13.
//

#import "AppDelegate.h"

#import "CanaryDemo-Bridging-Header.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "CanaryDemo-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CanaryManager *shared = CanaryManager.shared;
    shared.appSecret = @"82e439d7968b7c366e24a41d7f53f47d";
    shared.deviceId = UIDevice.currentDevice.identifierForVendor.UUIDString;
    shared.baseURL = @"http://127.0.0.1";
    if (CanaryMockURLProtocol.isEnabled) {
        [CanaryMockURLProtocol setIsEnabled:true];
    }
    shared.engine = [[UIManager alloc] init];
    [DDLog addLogger:CanaryTTYLogger.shared];
    [shared startLoggerWithDomain:@"http://127.0.0.1:9001" customProfile:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"test" : @"89897923561987341897", @"number": @10086, @"dict": @{@"extra": @"嵌套对象"}};
    }];
    return YES;
}

@end
