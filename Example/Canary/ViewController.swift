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
        var request = URLRequest.init(url: URL.init(string: "https://y.neverland.life/api/conf/full?appkey=com.binaryparadise.neverland&os=iOS")!)
//        request.httpBody = "{\"test\": \"param\"}".data(using: String.Encoding.utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            CNManager()?.storeNetworkLogger(CNNetLogMessage.init(reqest: request, resposne: response as! HTTPURLResponse, data: data!))
        }.resume()
    }

}
