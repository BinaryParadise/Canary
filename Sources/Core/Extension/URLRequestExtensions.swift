//
//  URLRequestExtensions.swift
//  Canary
//
//  Created by Rake Yang on 2021/1/5.
//

import Foundation
import WebKit
import SwiftyJSON
import SwifterSwift

#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV
import MobileCoreServices
import UIKit
#else
import CoreServices
#endif

extension URLRequest {
    static func get(with path: String, completion: ((Result, Error?) -> Void)?) -> Void {
        let r = NSMutableURLRequest(url: URL(string: "\(CanaryManager.shared.baseURL ?? "")\(path)")!)
        r.httpMethod = "GET"
        if let user = CanaryManager.shared.user() {
            r.setValue(user.token, forHTTPHeaderField: "Canary-Access-Token")
        }
        r.setValue(userAgent(), forHTTPHeaderField: "User-Agent")
        print("GET \(r.url?.absoluteString ?? "")")
        URLSession.shared.dataTask(with: r as URLRequest) { (data, response, error) in
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            if status == 401 {
                CanaryManager.shared.logout()
                DispatchQueue.main.async {
                    CanaryManager.shared.show()
                }
                return
            }
            DispatchQueue.main.async {
                do {
                    let result = try JSONDecoder().decode(Result.self, from: data ?? Data())
                    completion?(result, error)
                } catch {
                    completion?(Result(code: 1, msg: error.localizedDescription, data: nil, timestamp: Date().timeIntervalSince1970), error)
                }
            }
        }.resume()
    }
    
    static func post(with path: String, params: [String : AnyHashable]?, completion: ((Result, Error?) -> Void)?) -> Void {
        let r = NSMutableURLRequest(url: URL(string: "\(CanaryManager.shared.baseURL ?? "")\(path)")!)
        r.httpMethod = "POST"
        r.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let user = CanaryManager.shared.user() {
            r.setValue(user.token, forHTTPHeaderField: "Canary-Access-Token")
        }
        r.setValue(userAgent(), forHTTPHeaderField: "User-Agent")
        r.httpBody = params?.jsonData()
        print("POST \(r.url?.absoluteString ?? "")")
        URLSession.shared.dataTask(with: r as URLRequest) { (data, response, error) in
            DispatchQueue.main.async {
                do {
                    let result = try JSONDecoder().decode(Result.self, from: data ?? Data())
                    completion?(result, error)
                } catch {
                    completion?(Result(code: 1, msg: data?.string(encoding: .utf8), data: nil, timestamp: Date().timeIntervalSince1970), error)
                }
            }
        }.resume()
    }
    
    private static func userAgent() -> String {
        var userAgent: String
        #if os(macOS)
        userAgent = "" //TODO:
        #else
        let info = Bundle.main.infoDictionary!
        userAgent = "\(info[kCFBundleExecutableKey as String] ?? "")/\(info["CFBundleShortVersionString"]!) (\(UIDevice.current.model); iOS \(UIDevice.current.systemVersion); Scale/\(UIScreen.main.scale))"
        #endif
        return userAgent
    }
}
