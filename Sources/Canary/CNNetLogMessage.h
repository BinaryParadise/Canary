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

- (instancetype)initWithReqest:(NSURLRequest *)request resposne:(NSHTTPURLResponse *)response data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
