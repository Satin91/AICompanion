//
//  RequestModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation



struct RequestModel {
    var baseURL = ""
    var endpoint: ChatModel
    
    init(endpoint: ChatModel) {
        self.endpoint = endpoint
    }
    
    func makeRequest() -> URLRequest {
        var components = URLComponents()
        components.host = baseURL
        components.port = 3000
        components.scheme = "https"
        components.path = endpoint.path
        
        var request = URLRequest(url: components.url!)
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.addValue("shds-WJN3qNCLcxD3mOXuhchwGOVkF90", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        switch endpoint {
//            
//        case let .connect(cn, ip):
//            request.method = .post
//            let body: [String: Any] = ["cn": cn, "ip": ip]
//            let jsonData = try? JSONSerialization.data(withJSONObject: body)
//            request.httpBody = jsonData
//            
//        case .getStats:
//            request.method = .get
//            
//        case .traffic:
//            break
//            
//        case .getUsers:
//            request.method = .get
//            
//        case .deleteUser:
//            request.method = .delete
//            
//        }
        return request
    }
}
