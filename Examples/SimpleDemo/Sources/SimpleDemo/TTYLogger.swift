//
//  File.swift
//  
//
//  Created by Rake Yang on 2021/11/10.
//

import Foundation
import CocoaLumberjackSwift
import CanaryCore

public class CanaryTTYLogger: DDAbstractLogger {
    @objc static let shared = CanaryTTYLogger()
    public override func log(message logMessage: DDLogMessage) {
        CanaryManager.shared.storeLogMessage(dict: logMessage.dictionaryWithValues(forKeys: CanaryManager.StoreLogKeys), timestamp: logMessage.timestamp.timeIntervalSince1970)
    }
}
