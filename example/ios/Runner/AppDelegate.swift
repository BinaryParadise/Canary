import UIKit
import Flutter
import CocoaLumberjack
import flutter_canary

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      DDLog.add(DDTTYLogger.sharedInstance!)
      DDLog.add(CanaryLogger())
      DDLogInfo("launch")
      let t = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(onTimer(sender:)), userInfo: nil, repeats: true)
      RunLoop.current.add(t, forMode: .common)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    @IBAction func onTimer(sender: Timer) {
        DDLogInfo("hint test")
    }
}

class CanaryLogger: DDAbstractLogger {
    override func log(message logMessage: DDLogMessage) {
        //TODO: 将日志发送到金丝雀中
        let dict = logMessage.dictionaryWithValues(forKeys: StoreLogKeys)
        SwiftFlutterCanaryPlugin.storeLog(dict: dict)
    }
}
