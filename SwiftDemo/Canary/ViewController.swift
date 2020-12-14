//
//  ViewController.swift
//  Canary
//
//  Created by Rake Yang on 03/18/2020.
//  Copyright (c) 2020 Rake Yang. All rights reserved.
//

import UIKit
import Canary
import CocoaLumberjack

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DDLog.add(DDTTYLogger.sharedInstance!)
    }

    @IBAction func showConfig(_ sender: Any) {
        DDLogVerbose("verbose...")
        DDLogDebug("debug...")
        DDLogInfo("info...")
        DDLogWarn("warning...")
        DDLogError("error")
        
        CanarySwift.shared.show()
    }
    
    @IBAction func showNetLog(_ sender: Any) {
        
        NetworkManager.shared.request(requestType: .GET, urlString: "http://127.0.0.1:8081/api/canary/conf", parameters: nil) { (obj) in
            print("\(String(data: obj as? Data ?? Data(), encoding: .utf8))")
        }
    }
    
    @IBAction func showDoraemon(_ sender: Any) {
    }

}
