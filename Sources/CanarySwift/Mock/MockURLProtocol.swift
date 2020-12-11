//
//  MockURLProtocol.swift
//  Pods
//
//  Created by Rake Yang on 2020/12/10.
//

import Foundation

let MockURLProtocolHandledKey = "MockURLProtocolHandledKey"

/// 网络拦截器
class MockURLProtocol: URLProtocol {
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var sessionQueue = OperationQueue()
    static var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                URLProtocol.registerClass(self)
                MockManager.shared.fetchGroups {
                    
                }
            } else {
                URLProtocol.unregisterClass(self)
            }
        }
    }
    var receiveData = Data()
    
    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: MockURLProtocolHandledKey, in: request) as? Bool ?? false {
            return false
        }
        if ["http", "https"].contains(request.url?.scheme ?? "") {
            return MockManager.shared.shouldIntercept(for: request)
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let newRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        newRequest.url = MockManager.shared.mockURL(for: request)
        //标记请求已处理，防止循环
        URLProtocol.setProperty(true, forKey: MockURLProtocolHandledKey, in: newRequest)
        return newRequest.copy() as! URLRequest
    }
    
    override func startLoading() {
        if (self.request as NSURLRequest).mutableCopy() is NSMutableURLRequest {
            //使用URLSession从网络获取数据
            let defaultSession = URLSession(configuration: .default,
                                                       delegate: self, delegateQueue: sessionQueue)
            self.dataTask = defaultSession.dataTask(with: self.request)
            self.dataTask!.resume()
        }
    }
    
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
        self.receiveData.removeAll()
    }
}

extension MockURLProtocol: URLSessionTaskDelegate, URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        receiveData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}
