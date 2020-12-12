//
//  CanaryWebViewController.swift
//  Canary
//
//  Created by Rake Yang on 2020/1/7.
//  Copyright © 2020 BinaryParadise inc. All rights reserved.
//

let kMessageHandlerKey  = "cn_objc"
let kNativeCallBack = "nativeCallBack"

import WebKit

class CanaryWebViewController: UIViewController {
    var originURL: URL?
    private var wkWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: classForCoder)
        originURL = URL(string: bundle.path(forResource: "Canary.bundle/enter.html", ofType: nil) ?? "")
        
        //配置
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
    
        //注册自定义脚本
        config.userContentController.add(self, name: kMessageHandlerKey)
        
        wkWebView = WKWebView(frame: view.bounds, configuration: config)
        wkWebView?.navigationDelegate = self
        wkWebView?.uiDelegate = self
        view.addSubview(wkWebView!)
                
        refreshData()
    }
    
    func refreshData() {
        if originURL!.isFileURL {
            wkWebView?.loadFileURL(originURL!, allowingReadAccessTo: Bundle(for: classForCoder).resourceURL!)
        } else {
            wkWebView?.load(URLRequest(url: originURL!))
        }
    }
}

extension CanaryWebViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.request.url?.isFileURL ?? false {
            decisionHandler(.allow)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
            if UIApplication.shared.openURL(navigationAction.request.url!) {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { [weak self] (data, error) in
            self?.title = data as? String
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            completionHandler()
        }))
        present(alert, animated: true, completion: nil)
    }
}



extension CanaryWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == kMessageHandlerKey {
            let routeURL = URL(string: message.body as! String)
            if routeURL?.host == "testenter" {
                
            }
        }
    }
    
    
    func callbackFromNative(object: Any) {
        wkWebView?.evaluateJavaScript("\(kNativeCallBack)(\(object)", completionHandler: { (data, error) in
            print("\(#file)\(#function)+ \(#line)\(error)")
        })
    }
}
