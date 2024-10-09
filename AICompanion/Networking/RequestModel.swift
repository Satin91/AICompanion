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
    case getModels
}

extension RequestEnum {
    func makeRequest() -> URLRequest {
        switch self {
        case .sendMessages(model: let model, messages: let messages):
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
    let messages: [MessageModel]
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
        request.addValue(Constants.API.apiKeyGPTunnel, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
