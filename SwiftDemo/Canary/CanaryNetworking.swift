//
//  CanaryNetworking.swift
//  Canary_Example
//
//  Created by Rake Yang on 2020/12/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import AFNetworking

enum HTTPRequestType {
    case GET
    case POST
}
class NetworkManager: AFHTTPSessionManager {
    //单例：
    static let shared:NetworkManager = {
        let instence = NetworkManager()
        instence.requestSerializer = AFJSONRequestSerializer()
        instence.responseSerializer = AFHTTPResponseSerializer()
        instence.requestSerializer.setValue("application/json,text/html", forHTTPHeaderField: "Accept")
        instence.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return instence
    }()
    
    func request(requestType:HTTPRequestType,urlString:String,parameters:[String:AnyObject]?,complated:@escaping(AnyObject?)->()){
        
        let success = {
            (tasks:URLSessionDataTask,json:Any) ->() in complated(json as AnyObject?)
        }
        let failure = {
            (tasks:URLSessionDataTask?,error:Error) ->() in complated(nil)
        }
        
        if requestType == .GET {
            get(urlString, parameters: parameters, headers: nil, progress: nil, success: success, failure: failure)
        }else{
            self.post(urlString, parameters: parameters, headers: nil, progress: nil, success: success, failure: failure)
        }
    }
}
