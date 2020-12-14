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

    func matchScene(for request: URLRequest, sceneid: Int?) -> Int? {
        guard let match = scenes?.first(where: { (scene) -> Bool in
            scene.id == sceneid
        }) else { return nil }
        return match.id
    }
}

struct MockGroup: Codable {
    var id: Int
    var name: String
    var mocks: [MockData]?
}
