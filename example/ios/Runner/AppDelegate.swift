import UIKit
import Flutter
import CocoaLumberjack
import flutter_canary
import AFNetworking

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let mgr = AFHTTPSessionManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      mgr.responseSerializer = AFJSONResponseSerializer()
      DDLog.add(DDTTYLogger.sharedInstance!)
      DDLog.add(CanaryLogger())
      DDLogInfo("launch")
      let t = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(onTimer(sender:)), userInfo: nil, repeats: true)
      RunLoop.current.add(t, forMode: .common)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    @IBAction func onTimer(sender: Timer) {
        mgr.get("http://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp", parameters: nil, headers: nil, progress: nil) { task, data in
            //DDLogWarn("\(data)")
        } failure: { task, error in
            DDLogError("\(error)")
        }?.resume()
    }
}

class CanaryLogger: DDAbstractLogger {
    override func log(message logMessage: DDLogMessage) {
        //TODO: 将日志发送到金丝雀中
        let dict = logMessage.dictionaryWithValues(forKeys: StoreLogKeys)
        SwiftFlutterCanaryPlugin.storeLog(dict: dict)
    }
}
