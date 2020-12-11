//
//  ViewController.swift
//  Canary
//
//  Created by Rake Yang on 03/18/2020.
//  Copyright (c) 2020 Rake Yang. All rights reserved.
//

import UIKit
import Canary
import DoraemonKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DoraemonManager.shareInstance().pId = "6fee26c889bd6675da62b4e54d4b3edc"
        DoraemonManager.shareInstance().install()
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
        let request = URLRequest.init(url: URL.init(string: "https://y.neverland.life/api/conf/full?appkey=com.binaryparadise.neverland&os=iOS")!)
//        request.httpBody = "{\"test\": \"param\"}".data(using: String.Encoding.utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            CNManager()?.storeNetworkLogger(CNNetLogMessage.init(reqest: request, resposne: response as? HTTPURLResponse, data: data))
        }.resume()
    }
    
    @IBAction func showMockData(_ sender: Any) {
        CanarySwift.shared.showMock()
    }
    
    @IBAction func showDoraemon(_ sender: Any) {
        DoraemonManager.shareInstance().showDoraemon()
    }

}
