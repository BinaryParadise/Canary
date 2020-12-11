//
//  CanarySwift.swift
//  Canary
//
//  Created by Rake Yang on 2020/3/18.
//

import Foundation
import AFNetworking
import CocoaLumberjack
import SwiftyJSON

public class CanarySwift {
    
    /// 金丝雀服务域名
    public var baseURL: String?
    
    /// 设备唯一标识
    public var deviceId: String?
    
    /// 应用标识
    public var appSecret: String = ""
    
    /// 是否启用Mock
    public var isMockEnabled: Bool = false {
        didSet {
            MockURLProtocol.isEnabled = isMockEnabled
        }
    }
    public static let shared = CanarySwift()
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
    @objc public func startLogger(customProfile: @escaping (() -> [String: Any])) {
        TTYLoggerAdapter.shared.customProfile = customProfile
        let url = URL(string: baseURL!)!
        let port = url.port == nil ? "": ":\(url.port!)"
        TTYLoggerAdapter.shared.start(with: URL(string: "\(url.scheme!)://\(url.host!)\(port)/api/channel")!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(af_didRquestDidFinish(notification:)), name: NSNotification.Name.AFNetworkingTaskDidComplete, object: nil)
    }

    @objc func af_didRquestDidFinish(notification: NSNotification) {
        guard let task = notification.object as? URLSessionTask else { return }
        guard let request = task.originalRequest as NSURLRequest? else { return }
        guard let response = task.response as? HTTPURLResponse else { return }
                        
        let responseObject = notification.userInfo![AFNetworkingTaskDidCompleteSerializedResponseKey];
        let responseData = notification.userInfo![AFNetworkingTaskDidCompleteResponseDataKey];
        guard let _ = responseObject as? Array<Any> else { return }
        guard let _ = responseObject as? Dictionary<AnyHashable, Any> else { return }
        storeNetworkLogger(netLog: NetLogMessage(request: request, response: response, data: responseData as? Data))
    }

    func storeNetworkLogger(netLog: NetLogMessage) {
        let timestamp = Date().timeIntervalSince1970*1000;
        
        let msg = WebSocketMessage(type: .netLogger);
        var mdict: [String: Any] = [:]
        mdict["flag"] = DDLogFlag.info
        mdict["method"] = netLog.method
        mdict["url"] = netLog.requestURL!.absoluteString;
        mdict["requestfields"] = netLog.allRequestHTTPHeaderFields
        mdict["responsefields"] = netLog.allResponseHTTPHeaderFields
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
            print("\(error)")
        }
        mdict["timestamp"] = timestamp
        mdict["statusCode"] = netLog.statusCode
        mdict["type"] = 2
        msg.data = JSON(mdict);
        CanaryWebSocket.shared.sendMessage(message: msg)
    }
}
