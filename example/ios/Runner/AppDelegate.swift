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
      ExampleTestPlugin.register(with: registrar(forPlugin: "ExampleTestPlugin")!)
      DDLog.add(DDTTYLogger.sharedInstance!)
      DDLog.add(CanaryLogger())
      DDLogInfo("launch")
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class CanaryLogger: DDAbstractLogger {
    override func log(message logMessage: DDLogMessage) {
        //TODO: 将日志发送到金丝雀中
        let dict = logMessage.dictionaryWithValues(forKeys: StoreLogKeys)
        SwiftFlutterCanaryPlugin.storeLog(dict: dict)
    }
}
