//
//  CNManager.m
//  Canary
//
//  Created by Rake Yang on 2020/2/22.
//  Copyright © 2020 BinaryParadise. All rights reserved.
//

#import "CNManager.h"
#import "MCFrontendKitViewController.h"
#define kMCSuiteName @"com.binaryparadise.frontendkit"
#define kMCRemoteConfig @"remoteConfig"
#define kMCCurrentName @"currenName"
#import <AFNetworking/AFNetworking.h>
#import "CNNetLogMessage.h"

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

- (void)fetchRemoteConfig:(void (^)(void))completion {
    NSString *confURL = [NSString stringWithFormat:@"%@/api/conf/full?appkey=%@", self.baseURL.absoluteURL, self.appSecret];
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
            NSData *data = [NSJSONSerialization dataWithJSONObject:self.remoteConfig options:NSJSONWritingPrettyPrinted error:nil];
            [self.frontendDefaults setObject:data forKey:kMCRemoteConfig];
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

@end
