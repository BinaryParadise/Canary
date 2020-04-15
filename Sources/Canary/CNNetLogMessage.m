//
//  CNNetLogMessage.m
//  Canary
//
//  Created by Rake Yang on 2020/3/21.
//  Copyright © 2020年 BinaryParadise inc. All rights reserved.
//

#import "CNNetLogMessage.h"
#import <objc/runtime.h>

@implementation CNNetLogMessage

- (instancetype)initWithSessionTask:(NSURLSessionTask *)task data:(NSData *)data {
    if (self = [super init]) {
        NSURLRequest *request = task.currentRequest;
        self.method = request.HTTPMethod;
        self.requestURL = request.URL;
        self.allRequestHTTPHeaderFields = request.allHTTPHeaderFields;
        self.requestBody = request.HTTPBody;
        if (!self.requestBody) {
            self.requestBody = [self bodyData:request.HTTPBodyStream];
        }
        NSHTTPURLResponse *response = (id)task.response;
        self.allResponseHTTPHeaderFields = response.allHeaderFields;
        self.responseBody = data;
        self.statusCode = response.statusCode;
    }
    return self;
}

- (instancetype)initWithSessionTask:(NSURLSessionTask *)task metrics:(NSURLSessionTaskMetrics *)metrics  {
    if (self = [self initWithSessionTask:task data:task.cn_receiveData]) {
        self.metrics = metrics;
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

@implementation NSURLSessionTask (Canary)

- (void)setCn_receiveData:(NSData *)cn_receiveData {
    objc_setAssociatedObject(self, @selector(cn_receiveData), cn_receiveData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSData *)cn_receiveData {
    return objc_getAssociatedObject(self, _cmd);
}

@end
