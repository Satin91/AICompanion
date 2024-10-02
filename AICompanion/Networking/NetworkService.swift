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
    
    func sendMessage(message: String, companion: CompanionType) -> AnyPublisher<ResponseModel, NetworkError> {
        let request = RequestEnum.sendMessage(model: .gpt4o, role: "user", content: message).makeRequest()
        return networkManager.request(request: request)
    }
    
    func getBalance() -> AnyPublisher<Balance, NetworkError> {
        let request = RequestEnum.getBallance.makeRequest()
        return networkManager.request(request: request)
    }
}
