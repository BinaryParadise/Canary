//
//  CanarySwift.swift
//  Canary
//
//  Created by Rake Yang on 2020/3/18.
//

import Foundation

public class CanarySwift {
    public var baseURL: String?
    public var appSecret: String = ""
    public var isMockEnabled: Bool = false {
        didSet {
            MockURLProtocol.isEnabled = isMockEnabled
        }
    }
    public static let shared = CanarySwift()
    @objc public func showMock() {
        assert(baseURL != nil, "请初始化baseURL")
        assert(appSecret.count > 0, "请初始化AppSecret")
        let nav = UINavigationController(rootViewController: MockGroupViewController())
        nav.modalPresentationStyle = .overFullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
    }
    
    public func requestURL(with path:String) -> URL {
        return URL(string: "\(baseURL ?? "")\(path)\(path.contains("?") ? "&":"?")appsecret=\(appSecret)")!
    }
}
