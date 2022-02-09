//
//  MockManager.swift
//  Pods
//
//  Created by Rake Yang on 2020/12/10.
//

import Foundation
import SwiftyJSON
#if os(macOS)
import CanaryProto
#endif

let suiteName       = "com.binaryparadise.canary"
let MockGroupURL    = "/api/mock/app/whole"
let GroupsStore     = "GroupsStore"

struct Result: Codable {
    var code: Int
    var msg: String?
    var data: JSON?
    var timestamp: TimeInterval
}

@objc public class MockManager: NSObject {
    
    @objc public static let shared = MockManager()
    
    func checkIntercept(for request: URLRequest) -> (should:Bool, url: URL?) {
        let sema = DispatchSemaphore(value: 0)
        var args: [String : AnyHashable]?
        if request.httpMethod!.uppercased() == "GET" {
            args = request.url?.queryParameters
        } else {
            args = (try? JSONSerialization.jsonObject(with: request.httpBodyData ?? Data(), options: [])) as? [String : AnyHashable]
        }
        var should:Bool = false
        var url: URL?
        SwiftFlutterCanaryPlugin.instance.channel.invokeMethod("checkIntercept", arguments: NSDictionary(dictionary: ["url": request.url!.absoluteString, "params": args])) { result in
            if let r = result as? [String : AnyHashable] {
                should = r["intercept"] as? Bool ?? false
                if let s = r["url"] as? String {
                    url = URL(string: s);
                }
            }
            sema.signal()
        }
        sema.wait()
        return (should, url)
    }
    
    // 替换参数占位正则表达式
    func matchParameter(path: String) -> String {
        do {
            let mstr = NSString(string: path).mutableCopy() as! NSMutableString
            let regex = try NSRegularExpression(pattern: "\\{param[0-9]+\\}", options: .caseInsensitive)
            _ = regex.replaceMatches(in: mstr, options: .reportProgress, range: NSRange(location: 0, length: path.count), withTemplate: "([0-9./-A-Za-z]+)")
            return mstr as String
        } catch {
            print("\(error)")
        }
        return path
    }
}
