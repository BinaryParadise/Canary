import Flutter
import UIKit

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

public class SwiftFlutterCanaryPlugin: NSObject, FlutterPlugin {
    static let instance = SwiftFlutterCanaryPlugin()
    var channel: FlutterMethodChannel!
    var baseURL: String?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
      instance.channel = FlutterMethodChannel(name: "flutter_canary", binaryMessenger: registrar.messenger())
      registrar.addMethodCallDelegate(instance, channel: instance.channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      #if DEBUG
      print("method: \(call.method) args: \(call.arguments ?? "nil"), \(call)")
      #endif
      if call.method == "getPlatformVersion" {
          result("iOS " + UIDevice.current.systemVersion)
      } else if call.method == "enableNetLog" {
          enableNetLog(mode: call.arguments as? String)
          result(true)
      } else if call.method == "enableMock" {
          CanaryMockURLProtocol.isEnabled = call.arguments as? Bool ?? false;
          result(true)
      } else if call.method == "configure" {
          if let dict = call.arguments as? [String: Any],let url = dict["baseUrl"] as? String {
              baseURL = url
          }
          result(true)
      }
  }
    
    public static func storeLog(dict: [String : Any]) {
        var dict = dict;
        if let date = dict["timestamp"] as? Date {
            dict["timestamp"] = date.timeIntervalSince1970 * 1000
        }
        dict["type"] = 1
        
        instance.channel.invokeMethod("forwardLog", arguments: dict)
    }
    
    func enableNetLog(mode: String? = nil) {
        if let mode = mode {
            if mode == "NetLogMode.AFNetworking" {
                NotificationCenter.default.addObserver(self, selector: #selector(af_didRquestDidFinish(notification:)), name: NSNotification.Name(rawValue: "com.alamofire.networking.task.complete"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(af_didRquestDidFinish(notification:)), name: Notification.Name(rawValue: "org.alamofire.notification.name.task.didComplete"), object: nil)
            } else {
                fatalError("\(mode) not implement.")
            }
        }
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
        let timestamp = Date().timeIntervalSince1970*1000;
        
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
        channel.invokeMethod("forwardLog", arguments: mdict)
    }
}
