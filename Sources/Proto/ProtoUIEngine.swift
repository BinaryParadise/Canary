//
//  ProtoUIEngine.swift
//  Canary
//
//  Created by Rake Yang on 2021/11/10.
//

import Foundation

#if os(Linux)
public protocol ProtoUIEngine {
    func show()
}
#else
@objc public protocol ProtoUIEngine {
    func show()
}
#endif
