//
//  ViewController.swift
//  Canary
//
//  Created by Rake Yang on 03/18/2020.
//  Copyright (c) 2020 Rake Yang. All rights reserved.
//

import UIKit
import Canary

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func showConfig(_ sender: Any) {
        DDLogVerbose("verbose...")
        DDLogDebug("debug...")
        DDLogInfo("info...")
        DDLogWarn("warning...")
        DDLogError("error")
        
        CNManager()?.show()
    }
    
    @IBAction func showNetLog(_ sender: Any) {
        let request = URLRequest.init(url: URL.init(string: "http://127.0.0.1:8081/api/canary/conf")!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("\(String(data: data ?? Data(), encoding: .utf8))")
        }.resume()
    }
    
    @IBAction func showMockData(_ sender: Any) {
        CanarySwift.shared.showMock()
    }
    
    @IBAction func showDoraemon(_ sender: Any) {
    }

}
