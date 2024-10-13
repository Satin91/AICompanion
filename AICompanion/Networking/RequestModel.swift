//
//  RequestModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation



enum RequestEnum {
    case sendMessages(model: CompanionType, messages: [MessageModel])
    case getBallance
}

extension RequestEnum {
    var request: URLRequest {
        switch self {
        case .sendMessages(let model, let messages):
            switch model {
            case .claude3_5_sonnet:
                var request = RequestModel(
                    baseURL: Constants.API.sonnetBaseURL,
                    method: .post
                ).makeRequest()
                let message = messages.last?.content ?? ""
                let history: [MessageModel]? = messages.count > 1 ? messages : nil
                let requestModel = ClaudeBodyModel(message: message, api_key: Constants.API.apiKeyChadAi, history: history)
                let encoded = try! JSONEncoder().encode(requestModel)
                request.httpBody = encoded
                return request
            default:
                var request = RequestModel(
                    baseURL: Constants.API.gpTunnelSendMessageURL,
                    method: .post,
                    headers: [(Constants.API.apiKeyGPTunnel,"Authorization"),("application/json", "Content-Type" )]
                ).makeRequest()
                let event = GPTunnelBodyModel(model: model.rawValue, messages: messages)
                request.httpBody = try! JSONEncoder().encode(event)
                return request
            }
        case .getBallance:
            let request = RequestModel(
                baseURL: Constants.API.getBalanceURL,
                method: .get,
                headers: [(Constants.API.apiKeyGPTunnel,"Authorization"), ("application/json", "Content-Type" )]).makeRequest()
            return request
        }
    }
}

struct GPTunnelBodyModel: Codable {
    let model: String
    let messages: [MessageModel]
}

struct ClaudeBodyModel: Codable {
    var message: String
    var api_key: String
    var history: [MessageModel]?
}



struct RequestModel {
    
    var baseURL = ""
    var method = HTTPMethod.get
    var headers: [(value: String, header:String)] = []
    
    init(baseURL: String, method: HTTPMethod, headers: [(String, String)] = []) {
        self.baseURL = baseURL
        self.method = method
        self.headers = headers
    }
    
    func makeRequest() -> URLRequest {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        
        for headerValue in headers {
            request.addValue(headerValue.value, forHTTPHeaderField: headerValue.header)
        }
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
