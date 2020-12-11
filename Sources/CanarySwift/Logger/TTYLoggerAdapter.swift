//
//  TTYLoggerAdapter.swift
//  Canary
//
//  Created by Rake Yang on 2017/12/16.
//  Copyright © 2017年 BinaryParadise. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SwifterSwift
import SwiftyJSON

let keys = ["message",
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

class TTYLogger: DDAbstractLogger {
    static let shared = TTYLogger()

    override func log(message logMessage: DDLogMessage) {
        if CanaryWebSocket.shared.isReady() {
            let message = WebSocketMessage(type: .ttyLogger)
            var mdict = logMessage.dictionaryWithValues(forKeys: keys)
            mdict["appVersion"] = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
            mdict["timestamp"] = logMessage.timestamp.timeIntervalSince1970*1000
            mdict["deviceId"] = CanarySwift.shared.deviceId;
            mdict["type"] = 1;
            message.data = JSON(mdict)
            CanaryWebSocket.shared.sendMessage(message: message)
        }
    }
}

class TTYLoggerAdapter: NSObject {
    var customProfile: (() -> [String: Any])?
    static let shared = TTYLoggerAdapter()
    
    override init() {
        super.init()
        
        
    }
    
    func start(with domain: URL) -> Void {
        DDLog.add(TTYLogger.shared)
        CanaryWebSocket.shared.webSocketURL = domain.absoluteString
        CanaryWebSocket.shared.addMessageReciver(reciver: self)
        CanaryWebSocket.shared.start()
    }
    
    func register(webSocket: CanaryWebSocket) {
        let msg = WebSocketMessage(type: .registerDevice)
        let device = DeviceMessage()
        device.deviceId = CanarySwift.shared.deviceId
        device.appKey = CanarySwift.shared.appSecret;
        device.profile = customProfile?() as! [String : String]
        msg.data = JSON(device)
        webSocket.sendMessage(message: msg)
    }
}

extension TTYLoggerAdapter: WebSocketMessageProtocol {
    func webSocketDidOpen(webSocket: CanaryWebSocket) {
        register(webSocket: webSocket)
    }
    
    func webSocket(webSocket: CanaryWebSocket, didReceive message: WebSocketMessage) {
        
    }
    
    func webSocket(webSocket: CanaryWebSocket, didReceive pongPayload: Data?) {
        //更新设备信息
        register(webSocket: webSocket)
    }
}
