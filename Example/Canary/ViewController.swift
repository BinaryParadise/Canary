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
        
        CanaryManager.manager()?.show()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

