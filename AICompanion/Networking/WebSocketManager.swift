//
//  WebSocketManager.swift
//  AICompanion
//
//  Created by Arthur on 30.04.25.
//

import Foundation
import Combine

enum WebSocketError: Error {
    case disconnected
    case unknown(Error)
}

class WebSocketService {
    private var webSocketTask: URLSessionWebSocketTask?
    private let subject = PassthroughSubject<ResponseModel, NetworkError>()
    private var currentMessageIndex = 0
    
    func connect(url: URL) -> AnyPublisher<ResponseModel, NetworkError> {
        let url = URL(string: "ws://192.168.1.2:8082")!
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receive()
        return subject.eraseToAnyPublisher()
    }
    
    func send(_ text: String) {
        print("DEBUG: stream start text \(text)")
            webSocketTask?.send(.string(text)) { error in
                print("DEBUG: stream send text \(text)")
                if let error = error {
                    self.subject.send(completion: .failure(.serverError(code: 0, text: error.localizedDescription)))
                }
            }
    }
    
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("DEBUG: stream received text \(text)")
                    if text == "[END]" {
//                        self.subject.send(completion: .finished)
                        currentMessageIndex += 1
//                        self.webSocketTask?.cancel()
                    } else {
                        var response: ResponseModel = .init(message: text)
                        response.created = currentMessageIndex
                        self.subject.send(response)
                        self.receive() // слушаем дальше
                    }
                default:
                    print("DEBUG: stream listen firther")
                    self.receive() // слушаем дальше
                }
            case .failure(let error):
                print("DEBUG: stream listen failure \(error.localizedDescription)")
                self.subject.send(completion: .failure(.serverError(code: 0, text: error.localizedDescription)))
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        subject.send(completion: .failure(.notFound))
    }
}
