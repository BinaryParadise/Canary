//
//  CNManager.m
//  Canary
//
//  Created by Rake Yang on 2020/2/22.
//  Copyright © 2020 BinaryParadise. All rights reserved.
//

#import "CNManager.h"
#import "MCFrontendKitViewController.h"
#import "MCLoggerUtils.h"
#import "MCLogger.h"
#import "MCFrontendLogFormatter.h"
#import "Internal/MCDatabase.h"
#import "Internal/MCWebSocket.h"
#import <MJExtension/MJExtension.h>
#if TARGET_OS_IPHONE
#import "CNWebViewController.h"
#endif
#define kMCSuiteName @"com.binaryparadise.frontendkit"
#define kMCRemoteConfig @"remoteConfig"
#define kMCCurrentName @"currenName"

@interface CNManager ()

@property (nonatomic, copy) NSArray *remoteConfig;
@property (nonatomic, strong) NSUserDefaults *frontendDefaults;
@property (nonatomic, copy) NSDictionary *selectedConfig;
#if TARGET_OS_IOS
@property (nonatomic, strong) UIWindow *coverWindow;
#endif
@end

@implementation CNManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appKey = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleIdentifier"];
        self.deviceId = [MCLoggerUtils identifier];
        self.frontendDefaults = [[NSUserDefaults alloc] initWithSuiteName:kMCSuiteName];
        NSData *jsonData = [self.frontendDefaults objectForKey:kMCRemoteConfig];
        if (jsonData && [jsonData isKindOfClass:[NSData class]]) {
            self.remoteConfig = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        }
        if (!self.remoteConfig) {
            NSString *configPath = [NSBundle.mainBundle pathForResource:@"Peregrine.bundle/RemoteConfig.json" ofType:nil];
            if (configPath) {
                self.remoteConfig = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:configPath] options:NSJSONReadingMutableLeaves error:nil];
            }
        }
        _currentName = [self.frontendDefaults objectForKey:kMCCurrentName];
        [self switchToCurrentConfig];
    }
    return self;
}

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static CNManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [self.alloc init];
    });
    return instance;
}

- (void)setBaseURL:(NSURL *)baseURL {
    _baseURL = baseURL;
    [self fetchRemoteConfig:^{
        
    }];
}

- (void)setCurrentName:(NSString *)currentName {
    _currentName = currentName;
    [self.frontendDefaults setObject:currentName forKey:kMCCurrentName];
    [self.frontendDefaults synchronize];
    [self switchToCurrentConfig];
}

- (void)show {
#if TARGET_OS_IPHONE
    [self show:UIWindowLevelStatusBar+9];
}

- (void)show:(UIWindowLevel)level {

    UIWindow *window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:MCFrontendKitViewController.new];
    window.rootViewController = nav;
    window.windowLevel = level;
    [window makeKeyAndVisible];
    self.coverWindow = window;
//    nav.modalPresentationStyle = UIModalPresentationPopover;
//    UIViewController *popVC = UIApplication.sharedApplication.keyWindow.rootViewController;
//    if (popVC.presentedViewController) {
//        popVC = popVC.presentedViewController;
//    }
//    [popVC presentViewController:nav animated:YES completion:nil];

#else
    NSWindow *newWindow = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 300, 600) styleMask:NSWindowStyleMaskClosable|NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:YES];
    newWindow.contentViewController = [[MCFrontendKitViewController alloc] initWithNibName:nil bundle:[self resourceBundle]];
    newWindow.title = @"环境配置";
    newWindow.hasShadow = YES;
    [newWindow center];
    [newWindow orderFront:nil];
#endif
}

#if TARGET_OS_IPHONE

- (void)showWebView {
    UIWindow *window = [UIWindow.alloc initWithFrame:UIScreen.mainScreen.bounds];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:CNWebViewController.new];
    window.rootViewController = nav;
    window.windowLevel = UIWindowLevelStatusBar+10;
    [window makeKeyAndVisible];
    self.coverWindow = window;
}

+ (UIViewController *)cn_currentViewControoler {
    NSAssert([NSThread isMainThread], @"非主线程");
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *currentViewController = window.rootViewController;

    do {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    } while (YES);
    return currentViewController;
}

- (void)hide {
    [self.coverWindow removeFromSuperview];
    self.coverWindow = nil;
}
#endif

- (void)fetchRemoteConfig:(void (^)(void))completion {
    NSString *confURL = [NSString stringWithFormat:@"%@/api/conf/full?appkey=%@", self.baseURL.absoluteURL, self.appKey];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:[NSURL URLWithString:confURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [self processRemoteConfig:dict];
        } else {
            NSLog(@"%@", error);
        }
        if (completion) {
            completion();
        }
    }];
    [task resume];
}

- (void)processRemoteConfig:(NSDictionary *)dict {
    NSNumber *code = dict[@"code"];
    if (code.intValue == 0) {
        if ([dict[@"data"] isKindOfClass:[NSArray class]]) {
            self.remoteConfig = dict[@"data"];
            [self.frontendDefaults setObject:self.remoteConfig.mj_JSONData forKey:kMCRemoteConfig];
            [self switchToCurrentConfig];
        }
    }
}

- (void)switchToCurrentConfig {
    NSDictionary *selectedItem;
    NSDictionary *defaultItem;
    for (NSDictionary *group in self.remoteConfig) {
        for (NSDictionary *item in group[@"items"]) {
            if ([item[@"defaultTag"] boolValue]) {
                defaultItem = item;
            }
            if ([item[@"name"] isEqualToString:self.currentName]) {
                selectedItem = item;
            }
        }
    }
    
    if (!selectedItem) {
        selectedItem = defaultItem;
    }
    
    self.selectedConfig = selectedItem;
}

- (NSString *)stringForKey:(NSString *)key def:(NSString *)def {
    NSArray *subItems = self.selectedConfig[@"subItems"];
    NSDictionary *dict = [subItems filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name=%@", key]].firstObject;
    NSString *value = dict[@"value"];
    return value?:def;
}

#pragma mark - 日志监控

- (void)startLogMonitor:(NSDictionary<NSString *,id> *(^)(void))customProfileBlock {
    DDTTYLogger.sharedInstance.logFormatter = [MCFrontendLogFormatter new];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
    MCLogger.sharedInstance.customProfileBlock = customProfileBlock;
    [MCLogger.sharedInstance startWithAppKey:self.appKey domain:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@/channel", self.baseURL.scheme, self.baseURL.host, self.baseURL.port?[NSString stringWithFormat:@":%@",self.baseURL.port]:@""]]];
}

- (void)storeNetworkLogger:(id<CNNetworkLoggerProtocol>)netLog {
    NSMutableArray *args = [NSMutableArray array];
    NSTimeInterval timestamp = NSDate.date.timeIntervalSince1970*1000;
    [args addObject:@((NSUInteger)timestamp)];
    [args addObject:netLog.method];
    [args addObject:netLog.requestURL.absoluteString];
    [args addObject:netLog.allRequestHTTPHeaderFields.mj_JSONString?:NSNull.null];
    [args addObject:netLog.allResponseHTTPHeaderFields.mj_JSONString?:NSNull.null];
    [args addObject:netLog.requestBody?:NSNull.null];
    [args addObject:netLog.responseBody?:NSNull.null];
    [MCDatabase.defaultDB executeUpdate:@"INSERT INTO CNNetLog(timestamp, method,url,requestfields,responsefields,requestbody,responsebody) values(?, ?,?,?,?,?,?)" arguments:args];
    
    MCWebSocketMessage *msg = [MCWebSocketMessage messageWithType:MCMessageTypeNetLogger];
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    mdict[@"flag"] = @(DDLogFlagInfo);
    mdict[@"method"] = netLog.method;
    mdict[@"url"] = netLog.requestURL.absoluteString;
    mdict[@"requestfields"] = netLog.allRequestHTTPHeaderFields?:NSNull.null;
    mdict[@"responsefields"] = netLog.allResponseHTTPHeaderFields?:NSNull.null;
    if ([netLog.requestBody isKindOfClass:[NSData class]]) {
        mdict[@"requestbody"] = [NSJSONSerialization JSONObjectWithData:netLog.requestBody?:NSData.data options:NSJSONReadingMutableLeaves error:nil];
    } else {
        mdict[@"requestbody"] = netLog.requestBody?:@{};
    }
    if ([netLog.responseBody isKindOfClass:[NSData class]]) {
        mdict[@"responsebody"] = [NSJSONSerialization JSONObjectWithData:netLog.responseBody options:NSJSONReadingMutableLeaves error:nil];
    } else {
        mdict[@"responsebody"] = netLog.responseBody?:@{};
    }
    mdict[@"timestamp"] = @((NSUInteger)timestamp);
    mdict[@"statusCode"] = @(netLog.statusCode);
    mdict[@"type"] = @(2);
    msg.data = mdict;
    [MCWebSocket.shared sendMessage:msg];
}

- (NSBundle *)resourceBundle {
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:self.class].bundlePath stringByAppendingString:@"/Canary.bundle"]];
}

@end
