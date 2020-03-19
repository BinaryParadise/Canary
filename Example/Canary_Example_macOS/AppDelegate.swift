//
//  AppDelegate.swift
//  Canary_Example_macOS
//
//  Created by Rake Yang on 2020/3/19.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Cocoa
import Canary

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let manager = CanaryManager.manager()!
        manager.appKey = "com.binaryparadise.neverland"
        manager.enableDebug = true
        manager.baseURL = URL.init(string: "https://y.neverland.life")
        manager.startLogMonitor { () -> [String : Any]? in
            return ["test" : "89897923561987341897", "number": 10086, "dict": ["extra": "嵌套对象"]]
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func showConfig(sender:Any?) -> Void {
        DDLogWarn("日志测试")
        CanaryManager.manager()?.show()
    }

}

