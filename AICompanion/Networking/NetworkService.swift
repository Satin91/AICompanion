//
//  NetworkService.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import Combine

class NetworkService {
    var networkManager = NetworkManager()

    func sendMessage(message: [MessageModel], companion: CompanionType) -> AnyPublisher<ResponseModel, NetworkError> {
        if companion == .claude3_5_sonnet {
            let request = ClaudeRequestModel(message: message.last?.content ?? "" , api_key: Constants.API.apiKeyChadAi).makeRequest()
            return networkManager.request(request: request)
        }
        let request = RequestEnum.sendMessages(model: companion, messages: message).makeRequest()
        return networkManager.request(request: request)
    }
    
    func getBalance() -> AnyPublisher<Balance, NetworkError> {
        let request = RequestEnum.getBallance.makeRequest()
        return networkManager.request(request: request)
    }
}

struct ClaudeRequestModel: Codable {
    var message: String
    var api_key: String
    
    func makeRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: Constants.API.sonnetBaseURL)!)
        request.httpMethod = HTTPMethod.post.rawValue
        let encode = try! JSONEncoder().encode(self)
        request.httpBody = encode
        return request
    }
}
