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
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate

static void uncaughtExceptionHandler1(NSException *exception) {
    NSDictionary *dict = @{@"name": exception.name, @"reason": exception.reason, @"stackSymbols":exception.callStackSymbols, @"timestamp": [NSNumber numberWithLongLong:[NSDate date].timeIntervalSince1970 * 1000]};
    NSString *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject;
    NSString *fpath = [cache stringByAppendingFormat:@"/Canary/my_%@.json", dict[@"timestamp"]];
    if (![NSFileManager.defaultManager fileExistsAtPath:[cache stringByAppendingFormat:@"/Canary"]]) {
        [NSFileManager.defaultManager createDirectoryAtPath:[cache stringByAppendingFormat:@"/Canary"] withIntermediateDirectories:true attributes:nil error:nil];
    }
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [json writeToFile:fpath atomically:true];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler1);
    // Override point for customization after application launch.
    //[FIRApp configure];
    CanaryManager *shared = CanaryManager.shared;
    shared.appSecret = @"82e439d7968b7c366e24a41d7f53f47d";
    shared.deviceId = UIDevice.currentDevice.identifierForVendor.UUIDString;
    shared.baseURL = @"http://127.0.0.1";
    if (CanaryMockURLProtocol.isEnabled) {
        [CanaryMockURLProtocol setIsEnabled:true];
    }
    shared.engine = [[UIManager alloc] init];
    //[DDLog addLogger:CanaryTTYLogger.shared];
    [shared startLoggerWithDomain:@"http://127.0.0.1:9001" customProfile:^NSDictionary<NSString *,id> * _Nonnull{
        return @{@"test" : @"89897923561987341897", @"number": @10086, @"dict": @{@"extra": @"嵌套对象"}};
    }];
    return YES;
}

@end
