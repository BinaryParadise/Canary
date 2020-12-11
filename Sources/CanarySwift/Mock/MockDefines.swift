//
//  MockDefines.swift
//  Pods
//
//  Created by Rake Yang on 2020/12/11.
//

import Foundation

struct MockScene: Codable {
    var id: Int
    var name: String
}
struct MockData: Codable {
    var id: Int
    var name: String
    var path: String
    var scenes: [MockScene]?
    func activeScene() -> Int {
        return scenes?.first?.id ?? 0
    }
    
    func setScene(sceneid: Int) {
        
    }
    
    func match(for request: URLRequest) -> Bool {
        //TODO：更多匹配规则
        return scenes?.count ?? 0 > 0
    }
}

struct MockGroup: Codable {
    var id: Int
    var name: String
    var mocks: [MockData]?
}
