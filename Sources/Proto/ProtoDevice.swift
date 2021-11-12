//
//  File.swift
//  
//
//  Created by Rake Yang on 2021/6/16.
//

import Foundation
import SwiftyJSON
import Network

public struct ProtoDevice: Codable {
    public var ipAddrs: [String]?
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
        ipAddrs = Host.current().addresses
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
        ipAddrs = {
            var ips: [String] = []
            var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
            if getifaddrs(&ifaddr) == 0 {
                var ptr = ifaddr
                while (ptr != nil) {
                    let flags = Int32(ptr!.pointee.ifa_flags)
                    var addr = ptr!.pointee.ifa_addr.pointee
                    if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                        if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String(validatingUTF8:hostname) {
                                    let name = String(cString: ptr!.pointee.ifa_name)
                                    if name.hasPrefix("en") {
                                        ips.append(address)
                                    }
                                }
                            }
                        }
                    }
                    ptr = ptr!.pointee.ifa_next
                }
                freeifaddrs(ifaddr)
            }
            
            return ips
        }()

        simulator = TARGET_OS_SIMULATOR == 1
        #endif
    }
}
