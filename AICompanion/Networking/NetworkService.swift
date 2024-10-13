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
        let request = RequestEnum.sendMessages(model: companion, messages: message).request
        return networkManager.request(request: request)
    }
    
    func getBalance() -> AnyPublisher<Balance, NetworkError> {
        let request = RequestEnum.getBallance.request
        return networkManager.request(request: request)
    }
}

