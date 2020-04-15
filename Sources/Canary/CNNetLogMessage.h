//
//  CNNetLogMessage.h
//  Canary
//
//  Created by Rake Yang on 2020/3/21.
//  Copyright © 2020年 BinaryParadise inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNNetworkLoggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNNetLogMessage : NSObject <CNNetworkLoggerProtocol>

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSURL *requestURL;
@property (nonatomic, copy, nullable) NSDictionary *allRequestHTTPHeaderFields;
@property (nonatomic, copy, nullable) NSDictionary *allResponseHTTPHeaderFields;
@property (nonatomic, copy, nullable) NSData *requestBody;
@property (nonatomic, copy, nullable) NSData *responseBody;
@property (nonatomic, assign) NSUInteger statusCode;

/// 网络请求指标
@property (nonatomic, strong) NSURLSessionTaskMetrics *metrics API_AVAILABLE(ios(10.0));

- (instancetype)initWithSessionTask:(NSURLSessionTask *)task data:(NSData *)data;

- (instancetype)initWithSessionTask:(NSURLSessionTask *)task metrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0));

@end

@interface NSURLSessionTask (Canary)

@property (nonatomic, copy) NSData *cn_receiveData;

@end

NS_ASSUME_NONNULL_END
