//
//  ProtoSerializable.swift
//  
//
//  Created by Rake Yang on 2021/11/18.
//

import Foundation

extension Encodable {
    public func encodedData() -> Data? {
        do {
            return try JSONEncoder().encode(self)
        } catch {
            print("\(#function)+\(#line) \(error)")
        }
        return nil
    }
}
