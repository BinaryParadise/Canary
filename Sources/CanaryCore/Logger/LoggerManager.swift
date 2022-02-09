//
//  TTYLoggerAdapter.swift
//  Canary
//
//  Created by Rake Yang on 2017/12/16.
//  Copyright © 2017年 BinaryParadise. All rights reserved.
//

import Foundation
import SwiftyJSON
#if canImport(CanaryProto)
import CanaryProto
#endif

class LoggerManager: NSObject {
    var customProfile: (() -> [String: Any])?
    static let shared = LoggerManager()
    var updateTime = Date().timeIntervalSince1970
    static var beforeExceptionHandler: NSUncaughtExceptionHandler?
    
    override init() {
        super.init()
        LoggerManager.beforeExceptionHandler = NSGetUncaughtExceptionHandler()
        
        NSSetUncaughtExceptionHandler { exception in
            LoggerManager.storeCrash(exception)
        }
        
        reportCrashCache()
    }

    func start(with domain: URL) -> Void {
        CanaryWebSocket.shared.webSocketURL = domain.absoluteString
        CanaryWebSocket.shared.addMessageReciver(reciver: self)
        CanaryWebSocket.shared.start()
    }
    
    func addTTYLogger(dict:[String : Any], timestamp: TimeInterval) -> Void {
        if CanaryWebSocket.shared.isReady() {
            var message = ProtoMessage(type: .log)
            var mdict = dict
            mdict["appVersion"] = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
            mdict["timestamp"] = timestamp*1000
            mdict["deviceId"] = CanaryManager.shared.deviceId;
            mdict["type"] = 1;
            message.data = JSON(mdict)
            CanaryWebSocket.shared.sendMessage(message: message)
        }
    }
    
    func register(webSocket: CanaryWebSocket) {
        var msg = ProtoMessage(type: .register)
        var device = ProtoDevice(identify: CanaryManager.shared.deviceId ?? "")
        var dict: [String : JSON] = [:]
        customProfile?().forEach({ (key, value) in
            dict[key] = JSON(value)
        })
        device.profile = dict
        do {
            msg.data = try JSON(JSONEncoder().encode(device))
        } catch {
            print("\(#filePath).\(#function)+\(#line) \(error)")
        }
        webSocket.sendMessage(message: msg)
    }
    
    class func storeCrash(_ exception: NSException) {
        let dict = ["name": exception.name,
                    "reason": exception.reason as Any,
                    "stackSymbols":exception.callStackSymbols,
                    "stackAddresses": exception.callStackReturnAddresses,
                    "timestamp": Int64(Date().timeIntervalSince1970 * 1000)]
        if let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let fpath = "\(cache)/Canary"
            if !FileManager.default.fileExists(atPath: fpath) {
                try? FileManager.default.createDirectory(atPath: fpath, withIntermediateDirectories: true, attributes: nil)
            }
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) {
                try? data.write(to: URL(fileURLWithPath: "\(fpath)/\(Int64(Date().timeIntervalSince1970)).json"))
            }
        }
        
        beforeExceptionHandler?(exception)
        
    }
    
    /// 报告本地缓存的崩溃日志
    func reportCrashCache() {
        let queue = DispatchQueue(label: "report.crash")
        let cachePath = "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)/Canary"
        let subs = try? FileManager.default.subpathsOfDirectory(atPath: cachePath)
        for subPath in subs ?? [] {
            let filePath = URL(fileURLWithPath: "\(cachePath)/\(subPath)")
            if let dict = try? JSONSerialization.jsonObject(with: Data(contentsOf: filePath), options: .fragmentsAllowed) as? [String : AnyHashable] {
                queue.async {
                    URLRequest.custom(method: "PUT", path: "/api/crash/\(CanaryManager.shared.deviceId ?? "")", params: dict) { r, e in
                        if r.code == 0 {
                            try? FileManager.default.removeItem(at: filePath)
                        } else {
                            print("\(r.msg ?? "")")
                        }
                    }
                }
            }
        }
    }
}

extension LoggerManager: WebSocketMessageProtocol {
    func webSocketDidOpen(webSocket: CanaryWebSocket) {
        register(webSocket: webSocket)
    }
    
    func webSocket(webSocket: CanaryWebSocket, didReceive message: ProtoMessage) {
        if message.type == .update {
            //更新Mock配置
            MockManager.shared.fetchGroups(completion: nil)
        }
    }
    
    func webSocket(webSocket: CanaryWebSocket, didReceive pongPayload: Data?) {
        //更新设备信息
        register(webSocket: webSocket)
    }
}
