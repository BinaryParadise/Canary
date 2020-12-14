//
//  CanaryTTYLogger.swift
//  Canary_Example
//
//  Created by Rake Yang on 2020/12/13.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import CocoaLumberjack
import Canary

class CanaryTTYLogger: DDAbstractLogger {
    static let shared = CanaryTTYLogger()
    override func log(message logMessage: DDLogMessage) {
        CanarySwift.shared.storeLogMessage(dict: logMessage.dictionaryWithValues(forKeys: StoreLogKeys), timestamp: logMessage.timestamp.timeIntervalSince1970)
    }
}
