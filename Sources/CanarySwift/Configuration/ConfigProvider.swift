//
//  ConfigProvider.swift
//  Canary
//
//  Created by Rake Yang on 2020/12/11.
//

import Foundation

public class ConfigProvider {
    private var userDefaults = UserDefaults(suiteName: suiteName)!

    public static let shared = ConfigProvider()
        
    
}
