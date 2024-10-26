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
            var request = RequestModel(
                baseURL: model.baseURL,
                method: .post,
                headers: [("Bearer \(model.apiKey)","Authorization"),("application/json", "Content-Type" )]
            ).makeRequest()
            let messageBody = MessageBodyModel(modelEndpoint: model.rawValue, messages: messages)
            request.httpBody = try? JSONEncoder().encode(messageBody)
            return request
        case .getBallance:
            let request = RequestModel(
                baseURL: Constants.API.getBalanceURL,
                method: .get,
                headers: [(Constants.API.apiKeyGPTunnel,"Authorization"), ("application/json", "Content-Type" )]).makeRequest()
            return request
        }
    }
}

// MARK: - Model1
struct MessageBodyModel: Codable {
    let model: String
    var messages: [BodyMessage] = []
//    let maxTokens: Int = 1000000

    init(modelEndpoint: String, messages: [MessageModel]) {
        self.model = modelEndpoint
        convert(messages: messages)
    }
    
    mutating func convert(messages: [MessageModel]) {
        var resultMessages: [BodyMessage] = []
        for message in messages {
            var content: [MessageContent] = []
            
            // To save money, I sent the picture only from the last msg :)
            if let imageData = message.imageData, message == messages.last {
                let encodedString = imageData.base64EncodedString(options: .lineLength64Characters)
                let textMessage = MessageContent(type: "text", text: message.content, imageURL: nil)
                let imageMessage = MessageContent(type: "image_url", text: nil, imageURL: ImageURLWrapper(url: "data:image/png;base64,{\(encodedString)}"))
                content = [textMessage, imageMessage]
            } else {
                let textMessage = MessageContent(type: "text", text: message.content, imageURL: nil)
                content = [textMessage]
            }
            
            resultMessages.append(BodyMessage(role: message.role, content: content))
        }
        self.messages = resultMessages
    }
    
    enum CodingKeys: String, CodingKey {
        case model, messages
    }
}

struct BodyMessage: Codable {
    let role: String
    let content: [MessageContent]
}

struct MessageContent: Codable {
    let type: String
    let text: String?
    let imageURL: ImageURLWrapper?

    enum CodingKeys: String, CodingKey {
        case type, text
        case imageURL = "image_url"
    }
}

struct ImageURLWrapper: Codable {
    let url: String
}

// Used for ChadAI aggregator
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
    case put = "PUT"
    case delete = "DELETE"
}
