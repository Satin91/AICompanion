//
//  RequestModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation


struct EventMessage: Codable {
    let model: String
    let messages: [Message]
}

struct Message: Codable, Hashable {
    let role: String
    let content: String
    
    var isUser: Bool {
        return role != "assistant"
    }
}


struct RequestModel {
    
    var baseURL = "https://gptunnel.ru/v1/chat/completions"
    var model: ChatModel
    var message: String
    
    init(model: ChatModel, message: String) {
        self.model = model
        self.message = message
    }
    
    func makeRequest() -> URLRequest {
        let url = URL(string: baseURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("shds-WJN3qNCLcxD3mOXuhchwGOVkF90", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let message = EventMessage(model: model.rawValue, messages: [ .init(role: "user", content: message) ])
        
        do {
            let jsonData = try JSONEncoder().encode(message)
            request.httpBody = jsonData
        } catch {
            print("Error encode", error)
        }
        
        return request
    }
}
