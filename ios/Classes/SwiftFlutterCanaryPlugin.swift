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
    
  public static func register(with registrar: FlutterPluginRegistrar) {
      instance.channel = FlutterMethodChannel(name: "flutter_canary", binaryMessenger: registrar.messenger())
      registrar.addMethodCallDelegate(instance, channel: instance.channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
    
    public static func storeLog(dict: [String : Any]) {
        var dict = dict;
        if let date = dict["timestamp"] as? Date {
            dict["timestamp"] = date.timeIntervalSince1970 * 1000
        }
        dict["type"] = 1
        
        instance.channel.invokeMethod("forwardLog", arguments: dict)
    }
}
