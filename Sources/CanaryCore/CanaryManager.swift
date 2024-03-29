//
//  CanarySwift.swift
//  Canary
//
//  Created by Rake Yang on 2020/3/18.
//

import Foundation
import SwiftyJSON

#if canImport(CanaryProto)
import CanaryProto
#endif
#if os(macOS)
#else
import UIKit
#endif

@objc public class CanaryManager: NSObject {
    
    /// 金丝雀服务域名
    @objc public var baseURL: String?
    
    /// 设备唯一标识
    @objc public var deviceId: String?
    
    /// 应用标识
    @objc public var appSecret: String = ""
    
    private let lock = NSLock()
    
    private var _user: UserAuth?
        
    @objc public static let shared = CanaryManager()
    
    @objc public var engine: ProtoUIEngine?
    
    
    /// 日志对象Key集合
    @objc public static let StoreLogKeys = ["message",
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
        
    public override init() {
        if UserDefaults.standard.bool(forKey: "Canary.MockEnabled") {
            CanaryMockURLProtocol.isEnabled = true
        }
    }
    
    func setup() {
        if CanaryMockURLProtocol.isEnabled {
            MockManager.shared.fetchGroups(completion: nil)
        }
    }
    
    @objc public func show() {
        assert(baseURL != nil, "请初始化baseURL")
        assert(deviceId != nil, "请初始化deviceId")
        assert(appSecret.count > 0, "请初始化AppSecret")
        if lock.try() {
            engine?.show()
        }
    }
    
    @objc public func hide() {
        lock.unlock()
    }
    
    public func requestURL(with path:String) -> URL {
        return URL(string: "\(baseURL ?? "")\(path)\(path.contains("?") ? "&":"?")appsecret=\(appSecret)")!
    }
    
    func user() -> UserAuth? {
        let kc = Keychain(server: ServerHostKey, protocolType: .http)
        do {
            let r = try JSONDecoder().decode(UserAuth.self, from: kc.getData(UserAuthKey) ?? Data())
            _user = r
            return r
        } catch {
            
        }
        return _user
    }
    
    func logout() -> Void {
        CanaryMockURLProtocol.isEnabled = false
        _user = nil
        let kc = Keychain(server: ServerHostKey, protocolType: .http)
        do {
            try kc.remove(UserAuthKey)
        } catch {
            
        }
    }
}

extension CanaryManager {
    @objc public func startLogger(domain: String? = nil, customProfile: (() -> [String: Any])? = nil) {
        setup()
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
        NotificationCenter.default.addObserver(self, selector: #selector(af_didRquestDidFinish(notification:)), name: Notification.Name(rawValue: "org.alamofire.notification.name.task.didComplete"), object: nil)
    }
    
    @objc public func storeLogMessage(dict: [String : Any], timestamp: TimeInterval) {
        LoggerManager.shared.addTTYLogger(dict: dict, timestamp: timestamp)
    }

    @objc func af_didRquestDidFinish(notification: NSNotification) {
        var curTask = notification.object as? URLSessionTask //AFNetworking
        if curTask == nil {
            curTask = notification.userInfo?["org.alamofire.notification.key.task"] as? URLSessionTask
        }
        guard let task = curTask else { return }
        guard let request = task.originalRequest as NSURLRequest? else { return }
        guard let response = task.response as? HTTPURLResponse else { return }
                    
        let responseData = notification.userInfo?["com.alamofire.networking.complete.finish.responsedata"] as? Data
        if responseData == nil {
            _ = notification.userInfo?["org.alamofire.notification.key.responseData"]
        }
        DispatchQueue.global().async { [weak self] in
            self?.storeNetworkLogger(netLog: NetLogMessage(request: request, response: response, data: responseData))
        }
    }

    func storeNetworkLogger(netLog: NetLogMessage) {
        if !CanaryWebSocket.shared.isReady() {
            return
        }
        let timestamp = Date().timeIntervalSince1970*1000;
        
        var msg = ProtoMessage(type: .log);
        var mdict: [String: Any] = [:]
        mdict["identify"] = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        mdict["timestamp"] = timestamp
        if let sceneid = netLog.responseHeaderFields?["scene_id"] as? String {
            mdict["flag"] = 2 //DDLogFlag.DDLogFlagWarning
            let scenename = (netLog.responseHeaderFields?["scene_name"] as! String)
            mdict["url"] = netLog.requestURL!.absoluteString + "&scene_id=\(sceneid)&scene_name=\(scenename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        } else {
            mdict["flag"] = 4  //DDLogFlag.DDLogFlagInfo 1 << 2
            mdict["url"] = netLog.requestURL!.absoluteString;
        }
        mdict["method"] = netLog.method
        mdict["requestfields"] = netLog.requestHeaderFields
        mdict["responsefields"] = netLog.responseHeaderFields
        if let requestBody = netLog.requestBody {
            mdict["requestbody"] = (try? JSONSerialization.jsonObject(with: requestBody, options: .mutableLeaves)) ??
                String(data: requestBody, encoding: .utf8)
        }
        if let responseBody = netLog.responseBody {
            mdict["responsebody"] = (try? JSONSerialization.jsonObject(with: responseBody, options: .mutableLeaves)) ?? responseBody
        }
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
