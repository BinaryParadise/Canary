//
//  CNNetLogMessage.m
//  Canary
//
//  Created by Rake Yang on 2020/3/21.
//  Copyright © 2020年 BinaryParadise inc. All rights reserved.
//

#import "CNNetLogMessage.h"

@implementation CNNetLogMessage

- (instancetype)initWithReqest:(NSURLRequest *)request resposne:(NSHTTPURLResponse *)response data:(NSData *)data {
    if (self = [super init]) {
        self.method = request.HTTPMethod;
        self.requestURL = request.URL;
        self.allRequestHTTPHeaderFields = request.allHTTPHeaderFields;
        self.requestBody = request.HTTPBody;
        if (!self.requestBody) {
            self.requestBody = [self bodyData:request.HTTPBodyStream];
        }
        self.allResponseHTTPHeaderFields = response.allHeaderFields;
        self.responseBody = data;
        self.statusCode = response.statusCode;
    }
    return self;
}

- (NSData *)bodyData:(NSInputStream *)stream {
    uint8_t d[1024] = {0};
    NSMutableData *data = [[NSMutableData alloc] init];
    [stream open];
    while ([stream hasBytesAvailable]) {
        NSInteger len = [stream read:d maxLength:1024];
        if (len > 0 && stream.streamError == nil) {
            [data appendBytes:(void *)d length:len];
        }
    }
    [stream close];
    return data.length?data:nil;
}

@end
