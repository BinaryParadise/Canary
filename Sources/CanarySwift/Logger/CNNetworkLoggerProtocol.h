//
//  CNNetworkLoggerProtocol.h
//  Canary
//
//  Created by Rake Yang on 2020/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 网路日志协议
@protocol CNNetworkLoggerProtocol

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSURL *requestURL;
@property (nonatomic, copy, nullable) NSDictionary *allRequestHTTPHeaderFields;
@property (nonatomic, copy, nullable) NSDictionary *allResponseHTTPHeaderFields;
@property (nonatomic, copy, nullable) NSData *requestBody;
@property (nonatomic, copy, nullable) NSData *responseBody;
@property (nonatomic, assign) NSUInteger statusCode;

@end

NS_ASSUME_NONNULL_END
