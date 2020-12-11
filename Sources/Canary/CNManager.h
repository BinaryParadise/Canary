//
//  CNManager.h
//  Canary
//
//  Created by Rake Yang on 2020/2/22.
//  Copyright © 2020 BinaryParadise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNNetworkLoggerProtocol.h"

#define CNParam(_key, _def) [CNManager.manager stringForKey:_key def:_def]

@interface CNManager : NSObject

/// 前端服务地址，例如 https://frontend.zhegebula.top
@property (nonatomic, copy) NSURL *baseURL;

/// 设备唯一标识
@property (nonatomic, copy) NSString *deviceId;

/// 应用标识（添加应用生成的唯一标识）
@property (nonatomic, copy, nonnull) NSString *appSecret;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)manager;

#pragma mark - 环境配置

/// 所有环境配置
@property (nonatomic, copy, readonly) NSArray *remoteConfig;

/// 当前配置名称，未设置默认时自动取默认环境
@property (nonatomic, copy) NSString *currentName;

/// 是否启用调试模式，默认为NO
@property (nonatomic, assign) BOOL enableDebug;

/// 测试入口
@property (nonatomic, copy) NSArray * (^testEnterBlock)(void);

- (void)show;
#if TARGET_OS_IOS
- (void)show:(UIWindowLevel)level;
- (void)showWebView;
#endif
- (void)hide;

- (void)fetchRemoteConfig:(void (^)(void))completion;

/// 获取环境配置的参数值
/// @param key 参数键
/// @param def 默认值
- (NSString *)stringForKey:(NSString *)key def:(NSString *)def;

@end
