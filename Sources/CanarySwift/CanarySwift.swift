//
//  CanarySwift.swift
//  Canary
//
//  Created by Rake Yang on 2020/3/18.
//

import Foundation
import SwiftyJSON

@objc public class CanarySwift: NSObject {
    
    /// 金丝雀服务域名
    @objc public var baseURL: String?
    
    /// 设备唯一标识
    @objc public var deviceId: String?
    
    /// 应用标识
    @objc public var appSecret: String = ""
    
    @objc public static let shared = CanarySwift()
    @objc public func show() {
        assert(baseURL != nil, "请初始化baseURL")
        assert(deviceId != nil, "请初始化deviceId")
        assert(appSecret.count > 0, "请初始化AppSecret")
        let nav = UINavigationController(rootViewController: CanaryViewController())
        nav.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
    }
    
    public func requestURL(with path:String) -> URL {
        return URL(string: "\(baseURL ?? "")\(path)\(path.contains("?") ? "&":"?")appsecret=\(appSecret)")!
    }
}

extension CanarySwift {
    @objc public func startLogger(domain: String? = nil, customProfile: (() -> [String: Any])? = nil) {
        LoggerManager.shared.customProfile = customProfile
        if let domain = domain {
            let url = URL(string: domain)!
            let port = url.port == nil ? "": ":\(url.port!)"
            LoggerManager.shared.start(with: URL(string: "\(url.scheme!)://\(url.host!)\(port)/api/channel")!)
        } else {
            let url = URL(string: baseURL!)!
            let port = url.port == nil ? "": ":\(url.port!)"
            LoggerManager.shared.start(with: URL(string: "\(url.scheme!)://\(url.host!)\(port)/api/channel")!)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(af_didRquestDidFinish(notification:)), name: NSNotification.Name(rawValue: "com.alamofire.networking.task.complete"), object: nil)
    }
    
    @objc public func storeLogMessage(dict: [String : Any], timestamp: TimeInterval) {
        LoggerManager.shared.addTTYLogger(dict: dict, timestamp: timestamp)
    }

    @objc func af_didRquestDidFinish(notification: NSNotification) {
        guard let task = notification.object as? URLSessionTask else { return }
        guard let request = task.originalRequest as NSURLRequest? else { return }
        guard let response = task.response as? HTTPURLResponse else { return }
                        
        guard let responseData = notification.userInfo?["com.alamofire.networking.complete.finish.responsedata"] as? Data else { return }
        storeNetworkLogger(netLog: NetLogMessage(request: request, response: response, data: responseData))
    }

    func storeNetworkLogger(netLog: NetLogMessage) {
        let timestamp = Date().timeIntervalSince1970*1000;
        
        let msg = WebSocketMessage(type: .netLogger);
        var mdict: [String: Any] = [:]
        if let sceneid = netLog.responseHeaderFields?["scene_id"] as? String {
            mdict["flag"] = 2 //DDLogFlag.DDLogFlagWarning
            let scenename = (netLog.responseHeaderFields?["scene_name"] as! String)
            mdict["url"] = netLog.requestURL!.absoluteString + "&scene_id=\(sceneid)&scene_name=\(scenename.urlDecoded)"
        } else {
            mdict["flag"] = 4  //DDLogFlag.DDLogFlagInfo 1 << 2
            mdict["url"] = netLog.requestURL!.absoluteString;
        }
        mdict["method"] = netLog.method
        mdict["requestfields"] = netLog.requestHeaderFields
        mdict["responsefields"] = netLog.responseHeaderFields
        do {
            if netLog.requestBody != nil {
                mdict["requestbody"] = try JSONSerialization.jsonObject(with: netLog.requestBody ?? Data(), options: .mutableLeaves)
            } else {
                mdict["requestbody"] = netLog.requestBody
            }
            if netLog.responseBody != nil {
                mdict["responsebody"] = try JSONSerialization.jsonObject(with: netLog.responseBody ?? Data(), options: .mutableLeaves)
            } else {
                mdict["responsebody"] = netLog.responseBody
            }
        } catch {
            print("\(#file).\(#function)+\(#line)\(error)")
        }
        mdict["timestamp"] = timestamp
        mdict["statusCode"] = netLog.statusCode
        mdict["type"] = 2
        msg.data = JSON(mdict)
        CanaryWebSocket.shared.sendMessage(message: msg)
    }
    
    /// 获取当前环境的配置参数
    @objc public func stringValue(for key: String, def: String?) -> String? {
        return ConfigProvider.shared.stringValue(for: key, def: def)
    }
}

/// 日志对象Key集合
public let StoreLogKeys = ["message",
"level",
"flag",
"context",
"file",
"fileName",
"function",
"line",
"tag",
"options",
"timestamp",
"threadID",
"threadName",
"queueLabel"]
