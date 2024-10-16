//
//  RequestModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import UIKit


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
//                let messages = messages.map({ Message2(role: $0.role, content: [Content2(type: "text", text: $0.content, imageURL: nil)])})
                let event1 = GPTunnelBodyModel1(model: model.rawValue, messages: messages)
                print("Sendable event \(event1)")
                
                request.httpBody = try! JSONEncoder().encode(event1)
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

// MARK: - Model1
struct GPTunnelBodyModel1: Codable {
    let model: String
    var messages: [Message2] = []
    let maxTokens: Int = 300

    init(model: String, messages: [MessageModel]) {
        self.model = model
        convert(messages: messages)
    }
    
    mutating func convert(messages: [MessageModel]) {
        var resultMessages: [Message2] = []
        let image = UIImage(named: "photo")!.jpegData(compressionQuality: 0.3)!
        let encodedString = image.base64EncodedString()
        
        for message in messages {
            let textMessage = MessageContent(type: "text", text: message.content, imageURL: nil)
            print(encodedString)
            let imageMessage = MessageContent(type: "image_url", text: nil, imageURL: ImageURL2(url: "data:image/jpeg;base64,{\(encodedString)}"))
            
            
            
            
            if message.imageURL == nil {
                resultMessages.append(Message2(role: message.role, content: [textMessage]) )
            } else {
                resultMessages.append(Message2(role: message.role, content: [textMessage, imageMessage]))
            }
        }
        self.messages = resultMessages
    }
    
    enum CodingKeys: String, CodingKey {
        case model, messages
        case maxTokens = "max_tokens"
    }
}

// MARK: - Message
struct Message2: Codable {
    let role: String
    let content: [MessageContent]
}

// MARK: - Content
struct MessageContent: Codable {
    let type: String
    let text: String?
    let imageURL: ImageURL2?

    enum CodingKeys: String, CodingKey {
        case type, text
        case imageURL = "image_url"
    }
}

// MARK: - ImageURL
struct ImageURL2: Codable {
    let url: String
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
