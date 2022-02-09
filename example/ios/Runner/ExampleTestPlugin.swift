//
//  ExampleTestPlugin.swift
//  Runner
//
//  Created by Rake Yang on 2022/1/30.
//

import UIKit
import Flutter
import AFNetworking
import CocoaLumberjack

class ExampleTestPlugin: NSObject, FlutterPlugin {

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "canary_example_channel", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(ExampleTestPlugin(), channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "logger" {
            doLogger(call.arguments as? Bool ?? false)
            result(nil)
        } else if call.method == "logger-request" {
            doRequest()
            result(nil)
        }
    }
    
    func doLogger(_ all: Bool) {
        DDLogError("Error")
        if all {
            DDLogWarn("Warning")
            DDLogInfo("Info")
            DDLogDebug("Debug")
            DDLogVerbose("Verbose")
        }
    }
    
    func doRequest() {
        let mgr = AFHTTPSessionManager()
        mgr.responseSerializer = AFJSONResponseSerializer()
        mgr.get("http://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp", parameters: nil, headers: nil, progress: nil) { task, data in
            //DDLogWarn("\(data)")
        } failure: { task, error in
            DDLogError("\(error)")
        }?.resume()
    }
    
    deinit {
        print("\(#function)")
    }
}
