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
    
    func sendMessage(message: String) -> AnyPublisher<ResponseModel, NetworkError> {
        let request = RequestModel(model: .gpt4o, message: message).makeRequest()
        return networkManager.request(request: request)
    }
}
