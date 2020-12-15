//
//  MockManager.swift
//  Pods
//
//  Created by Rake Yang on 2020/12/10.
//

import Foundation
import SwiftyJSON

let suiteName = "com.binaryparadise.canary"

/// 接口状态
struct MockSwitch: Codable {
    var isEnabled: Bool
    var sceneId: Int?
    var automatic: Bool?
}

@objc public class MockManager: NSObject {
    private var userDefaults = UserDefaults(suiteName: suiteName)!
    
    /// 接口开关
    private var mockSwitchs: [String : MockSwitch] = [:]
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
        if let data = userDefaults.object(forKey: "switchs") as? Data {
            do {
                mockSwitchs = try JSONDecoder().decode([String: MockSwitch].self, from: data)
            } catch {
                
            }
        }
        fetchGroups {
            
        }
    }
    
    func switchFor(mockid: Int) -> MockSwitch {
        return mockSwitchs[mockid.string] ?? MockSwitch(isEnabled: false, sceneId: nil, automatic: false)
    }
    
    /// 设置接口状态
    func setSwitch(for mockid:Int, isOn: Bool) {
        var mockS = switchFor(mockid: mockid)
        mockS.isEnabled = isOn
        self.mockSwitchs[mockid.string] = mockS
        userDefaults.set(object: mockSwitchs, forKey: "switchs")
        userDefaults.synchronize()
    }
    
    /// 指定场景
    func setScene(for mockid:Int, sceneid: Int?) {
        var mockS = switchFor(mockid: mockid)
        mockS.sceneId = sceneid
        self.mockSwitchs[mockid.string] = mockS
        userDefaults.set(object: mockSwitchs, forKey: "switchs")
        userDefaults.synchronize()
    }
    
    @objc public func shouldIntercept(for request: URLRequest) -> Bool {
        //完全匹配
        let path = request.url?.path ?? ""
        var matchMock = mockMap[path]
        /*if matchMock == nil  {
            //正则匹配
            matchMock = mockMap.values.first(where: { (item) -> Bool in
                do {
                    //示例：/live/room/end/([0-9./-A-Za-z]+)
                    let regex = try NSRegularExpression(pattern: item.path, options: .caseInsensitive)
                    let count = regex.matches(in: path, options: .reportProgress, range: NSRange(location: 0, length: path.count)).count
                    if count > 0 {
                        return true
                    }
                } catch {
                    print("正则匹配：\(error)")
                }
                return false
            })
        }*/
        guard let mock = matchMock else { return false }
        let match = switchFor(mockid: mock.id)
        var intercept = false
        if match.isEnabled {
            intercept = mock.matchScene(for: request, sceneid: match.sceneId) != nil
        }
        return intercept
    }
    
    @objc public func mockURL(for request: URLRequest) -> URL? {
        guard let mock = mockMap[request.url?.path ?? ""] else { return nil }
        let match = switchFor(mockid: mock.id)
        let sceneid = mock.matchScene(for: request, sceneid: match.sceneId) ?? 0
        return URL(string: "\(CanarySwift.shared.baseURL ?? "")/api/mock/app/scene/\(sceneid)")
    }
    
    func fetchGroups(completion: @escaping (() -> Void)) -> Void {
        URLSession.shared.dataTask(with: CanarySwift.shared.requestURL(with: "/api/mock/whole")) { [weak self] (data, response, error) in
            do {
                let data = JSON(data)["data"]
                self?.groups = try JSONDecoder().decode([MockGroup].self, from: data.rawData())
            } catch {
                print("\(#file).\(#function)+\(#line)\(error)")
            }
            completion()
        }.resume()
    }
}
