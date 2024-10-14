//
//  ChatViewStore.swift
//  AICompanion
//
//  Created by Артур Кулик on 14.10.2024.
//

import Foundation
import Combine


struct ChatState {
    var navigationTitle: String = ""
    var isHistoryEnabled: Bool = false
    var isMessageReceiving = false
    var chat: ChatModel
}

enum ChatAction {
    case sendMessage(text: String, isHistoryEnabled: Bool)
    case delete(message: MessageModel)
    case receiveComplete(ChatModel)
    case errorReceiveMessage(error: NetworkError)
    case toggleHistoryValue
    case onViewAppear
}


class ChatViewStore: ViewStore {
    @Published var state: ChatState
    
    var network: NetworkService
    var chatsStorage: ChatsStorageInteractorProtocol
    var cancellable = Set<AnyCancellable>()
    
    
    init(initialState: ChatState, networkService: NetworkService, chatsStorage: ChatsStorageInteractorProtocol) {
        self.state = initialState
        self.network = networkService
        self.chatsStorage = chatsStorage
    }
    
    func reduce(state: inout ChatState, action: ChatAction) -> AnyPublisher<ChatAction, Never>? {
        switch action {
        case .sendMessage(let text, let isEnabled):
            state.chat.messages.append(MessageModel(role: "user", content: text))
            state.isMessageReceiving = true
            
            var model = state.chat
            let sendableMessage = MessageModel(role: "user", content: text)
            chatsStorage.updateChat(chat: model)
            return self.network
                .sendMessage(message: isEnabled ? model.messages : [sendableMessage], companion: model.companion)
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    let receivedMessage = MessageModel(role: "assistant", content: value.message)
                    model.messages.append(receivedMessage)
                    self.chatsStorage.updateChat(chat: model)
                    return .receiveComplete(model) }
                .catch { error in
                    return Just(.errorReceiveMessage(error: error))
                }
                .eraseToAnyPublisher()
        case .receiveComplete(let model):
            state.isMessageReceiving = false
            state.chat = model
        case .toggleHistoryValue:
            state.isHistoryEnabled.toggle()
        case .errorReceiveMessage(error: let error):
            state.isMessageReceiving = false
            switch error {
            case .notFound:
                state.navigationTitle = "Not found"
            case .cantDecodeThis(let text):
                state.navigationTitle = text
            case .serverError(let code, let text):
                state.navigationTitle = text
            }
        case .delete(message: let message):
            guard let firstIndex = state.chat.messages.firstIndex(of: message) else { return .none }
            state.chat.messages.remove(at: firstIndex)
        case .onViewAppear:
            state.navigationTitle = state.chat.companion.name
        }
        
        return .none
    }
    
    func asyncSendMessage(message: String, companion: CompanionType) async -> MessageModel {
        return await withUnsafeContinuation { continuation in
            
            network.sendMessage(message: [MessageModel(role: "user", content: message)], companion: companion)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    
                } receiveValue: { response in
                    let returningValue = MessageModel(role: "assistance", content: response.message)
                    continuation.resume(returning: returningValue)
                }
                .store(in: &cancellable)
        }
        
    }
    
    
    func asyncExecutes(state: inout ChatState, action: ChatAction) -> AnyPublisher<ChatAction, Never> {
        switch action {
        case .sendMessage(text: let text, isHistoryEnabled: let isEnabled):
            var model = state.chat
            let sendableMessage = MessageModel(role: "user", content: text)
            chatsStorage.updateChat(chat: model)
            return self.network
                .sendMessage(message: isEnabled ? model.messages : [sendableMessage], companion: model.companion)
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    let receivedMessage = MessageModel(role: "assistant", content: value.message)
                    model.messages.append(receivedMessage)
                    self.chatsStorage.updateChat(chat: model)
                    return .receiveComplete(model) }
                .catch { error in
                    return Just(.errorReceiveMessage(error: error))
                }
                .eraseToAnyPublisher()
        default: break
        }
        return Empty().eraseToAnyPublisher()
    }
    
//    func asyncExecutes() -> Middleware<ChatState, ChatAction> {
//        return { [weak self] state, action in
//            guard let self else { return .none}
//            switch action {
//            case .sendMessage(text: let text, isHistoryEnabled: let isEnabled):
//                var model = state.chat
//                let sendableMessage = MessageModel(role: "user", content: text)
//                chatsStorage.updateChat(chat: model)
//                return self.network
//                    .sendMessage(message: isEnabled ? model.messages : [sendableMessage], companion: model.companion)
//                    .subscribe(on: DispatchQueue.main)
//                    .map { value in
//                        let receivedMessage = MessageModel(role: "assistant", content: value.message)
//                        model.messages.append(receivedMessage)
//                        self.chatsStorage.updateChat(chat: model)
//                        return .receiveComplete(model) }
//                    .catch { (error: NetworkError) -> Just<ChatAction> in
//                        return Just(.errorReceiveMessage(error: error))
//                    }
//                    .eraseToAnyPublisher()
//            default: break
//            }
//            return Empty().eraseToAnyPublisher()
//        }
//    }
    
}

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

