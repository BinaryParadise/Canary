//
//  ViewController.m
//  Canary_Exampe_OC
//
//  Created by Rake Yang on 2020/3/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "ViewController.h"
#import <Canary/Canary.h>

@interface ViewController () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.urlSession = [NSURLSession sessionWithConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
}

- (IBAction)showConfig:(id)sender {
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithURL:[NSURL URLWithString:@"http://cip.cc"]];
    [dataTask resume];
    [CNManager.manager show];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (@available(iOS 10, *)) {
        dataTask.cn_receiveData = data;
    } else {
        [CNManager.manager storeNetworkLogger:[[CNNetLogMessage alloc] initWithSessionTask:dataTask data:data]];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(ios(10.0)){
    [CNManager.manager storeNetworkLogger:[[CNNetLogMessage alloc] initWithSessionTask:task metrics:metrics]];
}

@end
