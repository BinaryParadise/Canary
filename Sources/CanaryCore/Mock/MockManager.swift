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
    private var userDefaults = UserDefaults(suiteName: suiteName)!
    
    private var mockMap: [String : MockData] = [:]
    var groups: [MockGroup] = [] {
        didSet {
            groups.forEach { (group) in
                group.mocks?.forEach({ (mock) in
                    mockMap[mock.path] = mock
                })
            }
        }
    }
    @objc public static let shared = MockManager()
    override init() {
        super.init()
        do {
            self.groups = try JSONDecoder().decode([MockGroup].self, from: userDefaults.data(forKey: GroupsStore) ?? Data())
        } catch {
            
        }
        fetchGroups {
            
        }
    }
    
    func checkIntercept(for request: URLRequest) -> (should:Bool, url: URL?) {
        if let host = request.url?.host {
            if CanaryManager.shared.baseURL?.contains(host) ?? false {
                return (false, nil)
            }
        }
        //完全匹配
        let path = request.url?.path ?? ""
        if path == MockGroupURL || request.url?.host == CanaryManager.shared.baseURL {
            return (false, nil)
        }
        var matchMock = mockMap[path]
        if matchMock == nil  {
            //正则匹配
            matchMock = mockMap.values.first(where: { (item) -> Bool in
                do {
                    let regexStr = matchParameter(path: item.path)
                    let regex = try NSRegularExpression(pattern: regexStr, options: .caseInsensitive)
                    let count = regex.matches(in: path, options: .reportProgress, range: NSRange(location: 0, length: path.count)).count
                    if count > 0 {
                        return true
                    }
                } catch {
                    print("正则匹配：\(error)")
                }
                return false
            })
        }
        guard let mock = matchMock else { return (false, nil) }
        var intercept = false
        var url: URL?
        if mock.enabled {
            if let scendid = mock.matchScene(sceneid: mock.sceneid, request: request) {
                intercept = true
                var queryStr = ""
                if let q = request.url?.query {
                    queryStr.append("?\(q)")
                }
                url = URL(string: "\(CanaryManager.shared.baseURL ?? "")/api/mock/app/scene/\(scendid)\(queryStr)")
            }

        }
        return (intercept, url)
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
    
    func fetchGroups(completion: (() -> Void)?) -> Void {
        if CanaryMockURLProtocol.isEnabled {//启用Mock才需要获取配置
            URLRequest.get(with: MockGroupURL) { [weak self] (result, error) in
                do {
                    if result.code == 0 {
                        self?.groups = try JSONDecoder().decode([MockGroup].self, from: result.data?.rawData() ?? Data())
                        try self?.userDefaults.set(object: result.data?.rawData(), forKey: GroupsStore)
                    }
                } catch {
                    print("\(#file).\(#function) +\(#line) \(error)")
                }
                completion?()
            }
        }
    }
}
