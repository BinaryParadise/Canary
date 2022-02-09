//
//  MockDefines.swift
//  Pods
//
//  Created by Rake Yang on 2020/12/11.
//

import Foundation

struct AssociatedKeys {
    static var mockedURL = "mockedURL"
}

extension URL {
    /// SwifterSwift: Dictionary of the URL's query parameters
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else { return nil }

        var items: [String: String] = [:]

        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }

        return items
    }
    
    var mockedURL: URL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.mockedURL) as? URL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.mockedURL, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}
