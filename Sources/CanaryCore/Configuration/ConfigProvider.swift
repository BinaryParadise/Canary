//
//  ConfigProvider.swift
//  Canary
//
//  Created by Rake Yang on 2020/12/11.
//

import Foundation
import SwiftyJSON
#if canImport(CanaryProto)
import CanaryProto
#endif

let kMCRemoteConfig = "remoteConfig"
let kMCCurrentName  = "currenName"

public class ConfigProvider {
    private var userDefaults = UserDefaults(suiteName: suiteName)!
    var remoteConfig: [ProtoConfGroup] = []
    var selectedConfig: ProtoConf?
    var currentName: String? {
        willSet {
            userDefaults.set(newValue, forKey: kMCCurrentName)
            userDefaults.synchronize()
        }
    }
    
    public static let shared = ConfigProvider()
        
    init() {
        if let jsonData = userDefaults.string(forKey: kMCRemoteConfig)?.base64Decoded?.data(using: .utf8) {
            do {
                remoteConfig = try JSONDecoder().decode([ProtoConfGroup].self, from: jsonData)
            } catch {
                print("\(#file).\(#function)+\(#line)\(error)")
            }
        }
        if remoteConfig.count == 0 {
            if let configPath = Bundle.main.path(forResource: "Peregrine.bundle/RemoteConfig.json", ofType: nil) {
                do {
                    remoteConfig = try JSONDecoder().decode([ProtoConfGroup].self, from: Data(contentsOf: URL(fileURLWithPath: configPath)))
                } catch {
                    print("\(#file).\(#function)+\(#line) \n\(error)")
                }
            }
        }
        currentName = userDefaults.object(forKey: kMCCurrentName) as? String
        switchToCurrentConfig()
    }

    func fetchRemoteConfig(completion: @escaping (() -> Void)) {
        let confURL = "/api/conf/full?appkey=\(CanaryManager.shared.appSecret)"
        URLRequest.get(with: confURL) { [weak self] (result, error) in
            if result.code == 0 {
                self?.processRemoteConfig(data: result.data)
            } else {
                print("\(#function) \(error)")
            }
            completion()
        }
    }

    func processRemoteConfig(data: JSON?) {
        guard let data = data else { return }
        do {
            remoteConfig = try JSONDecoder().decode([ProtoConfGroup].self, from: data.rawData())
            userDefaults.set(data.rawString()?.base64Encoded, forKey: kMCRemoteConfig)
            switchToCurrentConfig()
        } catch {
            print("\(#file).\(#function)+\(#line) \(error)")
        }
    }

    func switchToCurrentConfig() {
        var selectedItem: ProtoConf?
        var defaultItem: ProtoConf?
        remoteConfig.forEach { (group) in
            group.items.forEach { (item) in
                if item.defaultTag {
                    defaultItem = item
                }
                if item.name == currentName {
                    selectedItem = item
                }
            }
        }
        
        if selectedItem == nil {
            selectedItem = defaultItem
        }
        
        if let selectedItem = selectedItem {
            currentName = selectedItem.name
        }
        
        selectedConfig = selectedItem
    }
    
    func stringValue(for key: String, def: String?) -> String? {
        let item = selectedConfig?.subItems?.first(where: { (subItem) -> Bool in
            return subItem.name == key
        })
        return item?.value ?? def
    }
}
