//
//  CanaryWebSocket.swift
//  Canary
//
//  Created by Rake Yang on 2020/12/11.
//

import Foundation
import Starscream
#if canImport(CanaryProto)
import CanaryProto
#endif
#if canImport(UIKit)
import UIKit
#endif

protocol WebSocketMessageProtocol: NSObjectProtocol {
    func webSocket(webSocket: CanaryWebSocket, didReceive message: ProtoMessage)

    func webSocketDidOpen(webSocket: CanaryWebSocket);

    func webSocket(webSocket: CanaryWebSocket, didReceive pongPayload: Data?)
}

class CanaryWebSocket: NSObject {
    var mySocket: WebSocket?
    var webSocketURL: String = ""
    static var shared = CanaryWebSocket()
    
    private var retry = true
    private let retryInterval:TimeInterval = 10
    private var recivers: [WebSocketMessageProtocol] = []
    private var pingTimer: Timer?
    
    private var canSend = false
    func isReady() -> Bool {
        return canSend
    }
    
    func start() {
        mySocket?.disconnect()
        var sysname: String = "Linux"
        #if os(iOS)
        sysname = UIDevice.current.systemName
        #elseif os(macOS)
        sysname = "Mac"
        #endif
        let baseURL = URL(string: "\(webSocketURL)/\(sysname)/\(CanaryManager.shared.deviceId!)")!
        let fullURL = URL(string: "\(baseURL.isTLSScheme ? "wss": "ws")://\(baseURL.host!)\(baseURL.path)")
        var mreq = URLRequest(url: fullURL!)
        mreq.setValue(CanaryManager.shared.appSecret, forHTTPHeaderField: "app-secret")
        mySocket = WebSocket(request: mreq)
        mySocket?.delegate = self
        
        if pingTimer == nil {
            pingTimer = Timer.scheduledTimer(timeInterval: retryInterval, target: self, selector: #selector(pingAction), userInfo: nil, repeats: true)
            RunLoop.main.add(pingTimer!, forMode: .default)
        }
        pingTimer?.fireDate = Date(timeIntervalSinceNow: retryInterval)
        mySocket?.connect()
        print("[Canary] 尝试连接到\(fullURL!)")
    }
    
    func stop() {
        pingTimer?.invalidate()
        mySocket?.disconnect()
    }

    func addMessageReciver(reciver: WebSocketMessageProtocol) {
        let has = recivers.contains { (msg) -> Bool in
            return msg.hash == reciver.hash
        }
        if !has {
            recivers.append(reciver)
        }
    }

    func sendMessage(message: ProtoMessage) {
        if isReady() {
            do {
                let data = try JSONEncoder().encode(message)
                mySocket?.write(data: data)
            } catch {
                print("\(#filePath).\(#function)+\(#line) \(error)")
            }
        }
    }
    
    @objc private func pingAction() {
        if(isReady()) {
            let t = Date().timeIntervalSince1970 * 1000
            mySocket?.write(ping: String(t).data(using: .utf8)!)
        }else {
            if (retry) {
                print("[Canary] \(retryInterval)秒后重试连接🍺");
                retry = false
                DispatchQueue.global().asyncAfter(deadline: .now()+retryInterval) { [weak self] in
                    self?.start()
                    self?.retry = true
                }
            }
        }
    }
}

extension CanaryWebSocket: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        
        case .connected(_):
            canSend = true
            recivers.forEach { (receiver) in
                receiver.webSocketDidOpen(webSocket: self)
            }
            print("[Canary] WebSocket连接成功：\(client.request.url?.absoluteString ?? "")🍺")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .init(rawValue: DeviceRegistertedNotificationKey), object: nil)
            }
        case .disconnected(let reason, let code):
            canSend = false
            print("[Canary] 连接关闭：\(code)-\(reason)🍺")
        case .text(_):
            break
        case .binary(let data):
            webSocket(client, didReceiveBinary: data)
        case .pong(let pongPayload):
            recivers.forEach { (receiver) in
                receiver.webSocket(webSocket: self, didReceive: pongPayload)
            }
        case .ping(_):
            break
        case .error(let error):
            print("[Canary] \(client.request.url?.absoluteString ?? "") \(error!)❌")
            if let error = error as NSError? {
                if error.code == 2133 || error.code == -72000 {
                    var components = URLComponents(string: webSocketURL)!
                    components.scheme = "wss"
                    webSocketURL = components.url?.absoluteString ?? ""
                }
            }
            canSend = false
            pingAction()
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        }
    }
    
    func webSocket(_ webSocket: WebSocket, didReceiveBinary data: Data) {
        do {
            let result = try JSONDecoder().decode(ProtoMessage.self, from: data)
            if result.code == 0 {
                recivers.forEach { (receiver) in
                    receiver.webSocket(webSocket: self, didReceive: result)
                }
            } else {
                print("\(result.msg ?? "")")
            }
        } catch {
            print("\(#filePath).\(#function)+\(#line) \(error)")
        }
    }
}
