//
//  CNWebViewController.m
//  vip8
//
//  Created by Rake Yang on 2020/1/7.
//  Copyright © 2020 xin818 inc. All rights reserved.
//

#import "CNWebViewController.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "CNManager.h"
#import <MJExtension/MJExtension.h>

#define kMessageHandlerKey  @"cn_objc"
#define kNativeCallBack @"nativeCallBack"

@interface CNWebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, copy) NSURL *originURL;

@property (nonatomic, strong) WKWebView *wkWebView;


@end

@implementation CNWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.originURL = [NSURL fileURLWithPath:[CNManager.manager.resourceBundle pathForResource:@"enter.html" ofType:nil]];
    
    //配置
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    webViewConfig.preferences = [WKPreferences new];
    
    //注册自定义脚本
    [webViewConfig.userContentController addScriptMessageHandler:self name:kMessageHandlerKey];
    
    //WKWebView
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webViewConfig];
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    [self.view addSubview:self.wkWebView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(closeView:)];
    
    [self refreshData];
}

- (void)closeView:(id)sender {
    [CNManager.manager hide];
    [self dismissViewControllerAnimated:YES completion:^{
        [CNManager.manager hide];
    }];
}

#pragma mark XCDataLoaderDelegate

- (void)refreshData {
    if (self.originURL.fileURL) {
        if (@available(iOS 9.0, *)) {
            [self.wkWebView loadFileURL:self.originURL allowingReadAccessToURL:CNManager.manager.resourceBundle.resourceURL];
        }
    } else {
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.originURL]];
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.request.URL.fileURL) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    [self closeView:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([UIApplication.sharedApplication openURL:navigationAction.request.URL]) {
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    });
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    __weak typeof(self) self_weak = self;
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        self_weak.title = data?:@"不知道";
    }];
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:kMessageHandlerKey]) {
        NSURL *routeURL = [NSURL URLWithString:message.body];
        if ([routeURL.host isEqualToString:@"testenter"] && CNManager.manager.testEnterBlock) {
            [self callbackFromNative:[CNManager.manager.testEnterBlock() mj_JSONString]];
        }
    }
}

- (void)callbackFromNative:(id)object {
    [self.wkWebView evaluateJavaScript:[NSString stringWithFormat:@"%@(%@)", kNativeCallBack, object] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

@end
