//
//  UIManager.swift
//  Canary
//
//  Created by Rake Yang on 2021/11/10.
//

import Foundation

@objc public class UIManager: NSObject, ProtoUIEngine {
    var nav: UINavigationController?
    
    public func show() {
        nav = UINavigationController(rootViewController: MajorViewController())
        nav?.modalPresentationStyle = .fullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(nav!, animated: true, completion: nil)
    }
    
    
}
