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

class MockManager {
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
    static let shared = MockManager()
    init() {
        if let data = userDefaults.object(forKey: "switchs") as? Data {
            do {
                mockSwitchs = try JSONDecoder().decode([String: MockSwitch].self, from: data)
            } catch {
                
            }
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
    
    func shouldIntercept(for request: URLRequest) -> Bool {
        guard let mock = mockMap[request.url?.path ?? ""] else { return false }
        if switchFor(mockid: mock.id).isEnabled {
            return mock.match(for: request)
        } else {
            return false
        }
    }
    
    func mockURL(for request: URLRequest) -> URL? {
        guard let mock = mockMap[request.url?.path ?? ""] else { return nil }
        return URL(string: "\(CanarySwift.shared.baseURL ?? "")/api/mock/app/scene/\(switchFor(mockid: mock.id).sceneId ?? 0)")
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
