//
//  ChatMiddlewares.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import Foundation
import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

func chatMiddleware(network: NetworkService, chatsStorage: ChatsStorageInteractorProtocol) -> Middleware<ChatState, ChatAction> {
    return { state, action in
        switch action {
        case .sendMessage(text: let text, isHistoryEnabled: let isEnabled):
            var model = state.chat
            let sendableMessage = MessageModel(role: "user", content: text)
            chatsStorage.updateChat(chat: model)
            return network
                .sendMessage(message: isEnabled ? model.messages : [sendableMessage], companion: model.companion)
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    let receivedMessage = MessageModel(role: "assistant", content: value.message)
                    model.messages.append(receivedMessage)
                    chatsStorage.updateChat(chat: model)
                    return .receiveComplete(model) }
                .catch { (error: NetworkError) -> Just<ChatAction> in
                    return Just(.errorReceiveMessage(error: error))
                }
                .eraseToAnyPublisher()
        default: break
        }
        return Empty().eraseToAnyPublisher()
    }
}
