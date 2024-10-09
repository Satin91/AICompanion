//
//  RequestModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation



enum RequestEnum {
    case sendMessage(model: CompanionType, role: String, content: String)
    case sendMessages(model: CompanionType, role: String, messages: [Message])
    case getBallance
    case getModels
}

extension RequestEnum {
    func makeRequest() -> URLRequest {
        switch self {
            
        case .sendMessage(let model, let role, let content):
            var request = RequestModel(baseURL: Constants.API.sendMessageURL, method: .post).makeRequest()
            do {
                let message = EventMessage(model: model.rawValue, messages: [ .init(role: "user", content: content)])
                let jsonData = try JSONEncoder().encode(message)
                request.httpBody = jsonData
            } catch {
                print("Error encode", error.localizedDescription)
            }
            return request
            
        case .sendMessages(model: let model, role: let role, messages: let messages):
            var request = RequestModel(baseURL: Constants.API.sendMessageURL, method: .post).makeRequest()
            
            do {
                let messages = EventMessage(model: model.rawValue, messages: messages)
                let jsonData = try JSONEncoder().encode(messages)
                request.httpBody = jsonData
            } catch {
                print("Error encode", error.localizedDescription)
            }

            return request
            
        case .getBallance:
            let request = RequestModel(baseURL: Constants.API.getBalanceURL, method: .get).makeRequest()
            return request
        case .getModels:
            let request = RequestModel(baseURL: "https://gptunnel.ru/v1/models", method: .get).makeRequest()
            return request
        }
    }
}

struct EventMessage: Codable {
    let model: String
    let messages: [Message]
}

struct Message: Codable, Hashable {
    let role: String
    let content: String
    
//    var isUser: Bool {
//        return role != "assistant"
//    }
}

struct EventBalance: Codable {
    
}

struct RequestModel {
    
    var baseURL = ""
    var method = HTTPMethod.get
    
    init(baseURL: String, method: HTTPMethod) {
        self.baseURL = baseURL
        self.method = method
    }
    
    func makeRequest() -> URLRequest {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(Constants.API.apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
