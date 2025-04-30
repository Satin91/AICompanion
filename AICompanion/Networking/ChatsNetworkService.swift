//
//  NetworkService.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import Combine

protocol ChatsNetworkServiceProtocol {
    func sendMessage(message: [MessageModel], companion: CompanionType) -> AnyPublisher<ResponseModel, NetworkError>
    func getBalance() -> AnyPublisher<Balance, NetworkError>
}

class ChatsNetworkService: ChatsNetworkServiceProtocol {
    var networkManager = NetworkManager()
    var webSocketService = WebSocketService()
    
    func sendMessage(message: [MessageModel], companion: CompanionType) -> AnyPublisher<ResponseModel, NetworkError> {
        switch companion {
        case .mistrallSmall:
            let url = URL(string: companion.baseURL)!
            return webSocketService.connect(url: url)
        default:
            let request = RequestEnum.sendMessages(model: companion, messages: message).request
            return networkManager.request(request: request)
        }
    }
    
    func connectToStream() -> AnyPublisher<ResponseModel, NetworkError> {
        return webSocketService.connect(url: URL(string: "https:/asdsdg")!)
    }
    
    func sendMessage(message: [MessageModel]) {
        webSocketService.send(message.last!.content)
    }
    
    func getBalance() -> AnyPublisher<Balance, NetworkError> {
        let request = RequestEnum.getBallance.request
        return networkManager.request(request: request)
    }
}

