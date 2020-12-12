//
//  MCFrontendLogFormatter.m
//  MCFrontendKit
//
//  Created by Rake Yang on 2020/2/26.
//

import CocoaLumberjack

class LoggerFormatter: NSObject, DDLogFormatter {    
    func format(message logMessage: DDLogMessage) -> String? {
        return "\(logMessage.fileName).\(logMessage.function ?? "")+\(logMessage.line) \(logMessage.message)"
    }
}
