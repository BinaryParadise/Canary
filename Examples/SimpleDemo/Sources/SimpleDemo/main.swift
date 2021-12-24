import CocoaLumberjack
import CocoaLumberjackSwift
import CanaryCore

DDLog.add(DDTTYLogger.sharedInstance!)
DDLog.add(CanaryTTYLogger())

DispatchQueue.main.asyncAfter(deadline: .now() + 10) {    
    DDLogDebug("xxx")
}

CanaryManager.shared.appSecret = "82e439d7968b7c366e24a41d7f53f47d"
CanaryManager.shared.deviceId = UUID().uuidString
CanaryManager.shared.baseURL = "http://127.0.0.1"
CanaryManager.shared.startLogger(domain: nil) {
    return ["test" : "89897923561987341897", "number": 10086, "dict": ["extra": "嵌套对象"]]
}

CFRunLoopRun()
