//
//  ViewController.m
//  CanaryDemo
//
//  Created by Rake Yang on 2020/12/13.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "CanaryDemo-Bridging-Header.h"
#import "CanaryDemo-Swift.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *logView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self fetchParam];
}

- (void)fetchParam {
    [self showLog:[NSString stringWithFormat:@"获取配置参数：A = %@", [CanaryManager.shared stringValueFor:@"A" def:@"123"]]];
}

- (void)showLog:(NSString *)log {
    NSLog(@"%@", log);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = log;
    });
}

- (IBAction)showCanary:(id)sender {
    [CanaryManager.shared show];
    [self fetchParam];
    DDLogVerbose(@"verbose");
    DDLogInfo(@"info");
    DDLogWarn(@"warn");
    DDLogDebug(@"degbu");
    DDLogError(@"error");
}

- (IBAction)showNetworking:(id)sender {
    
    NSLog(@"%@", NSURLSessionConfiguration.defaultSessionConfiguration.protocolClasses);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    manager.requestSerializer = AFHTTPRequestSerializer.serializer;
    manager.responseSerializer = AFJSONResponseSerializer.serializer;
    NSURLSessionDataTask *task = [manager GET:@"https://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self showLog:[NSString stringWithFormat:@"%@", responseObject]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showLog:[NSString stringWithFormat:@"%@", error]];
    }];
    [task resume];
    
}

- (IBAction)showNetworkingParam:(id)sender {
    NSLog(@"%@", NSURLSessionConfiguration.defaultSessionConfiguration.protocolClasses);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
    manager.requestSerializer = AFHTTPRequestSerializer.serializer;
    manager.responseSerializer = AFJSONResponseSerializer.serializer;
    NSURLSessionDataTask *task = [manager GET:@"http://quan.suning.com/getSysTime.do" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self showLog:[NSString stringWithFormat:@"%@", responseObject]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showLog:[NSString stringWithFormat:@"%@", error]];
    }];
    [task resume];
}


@end
