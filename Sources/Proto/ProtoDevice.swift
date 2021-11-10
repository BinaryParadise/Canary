//
//  File.swift
//  
//
//  Created by Rake Yang on 2021/6/16.
//

import Foundation
import SwiftyJSON

public struct ProtoDevice: Codable {
    public var ipAddrs: [String : [String : String]]?
    public var simulator: Bool
    public var appVersion: String
    public var osName: String
    public var osVersion: String
    public var modelName: String
    public var name: String
    public var profile: [String : JSON]?
    public var deviceId: String
    
    public init(identify: String) {
        deviceId = identify
        
        if let info = Bundle.main.infoDictionary, info.count > 0 {
            appVersion = info["CFBundleShortVersionString"] as! String
        } else {
            appVersion = "0.1.0"
        }
        #if os(macOS)
        let info = ProcessInfo.processInfo
        name = Host.current().localizedName ?? "Unknown"
        osName = "macOS"
        osVersion = "\(info.operatingSystemVersion.majorVersion).\(info.operatingSystemVersion.minorVersion).\(info.operatingSystemVersion.patchVersion)"
                
        modelName = {
            var size = 0
            sysctlbyname("hw.model", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0,  count: size)
            sysctlbyname("hw.model", &machine, &size, nil, 0)
            return String(cString: machine)
        }()
        simulator = TARGET_OS_SIMULATOR == 1
        #elseif os(Linux)
        let info = ProcessInfo.processInfo
        name = Host.current().localizedName ?? "Unknown"
        osName = "Linux"
        osVersion = "\(info.operatingSystemVersion.majorVersion).\(info.operatingSystemVersion.minorVersion).\(info.operatingSystemVersion.patchVersion)"
        modelName = "Linux"
        simulator = false
        #else
        name = UIDevice.current.name
        osName = UIDevice.current.systemName
        osVersion = UIDevice.current.systemVersion
        modelName = UIDevice.current.localizedModel
        simulator = TARGET_OS_SIMULATOR == 1
        #endif
    }
}
