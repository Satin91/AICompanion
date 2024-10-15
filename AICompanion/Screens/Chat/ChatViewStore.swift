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
    var chat: ChatModelObserver
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
    
    var network: ChatsNetworkService
    var chatsStorage: ChatsStorageInteractorProtocol
    var cancellable = Set<AnyCancellable>()
    
    init(initialState: ChatState, networkService: ChatsNetworkService, chatsStorage: ChatsStorageInteractorProtocol) {
        self.state = initialState
        self.network = networkService
        self.chatsStorage = chatsStorage
    }
    
    func reduce(state: inout ChatState, action: ChatAction) -> AnyPublisher<ChatAction, Never>? {
        switch action {
        case .sendMessage(let text, let isEnabled):
            state.chat.value.messages.append(MessageModel(role: "user", content: text))
            state.isMessageReceiving = true
            var model = state.chat.value
            let sendableMessage = MessageModel(role: "user", content: text)
//            chatsStorage.updateChat(chat: model)
            return self.network
                .sendMessage(message: isEnabled ? model.messages : [sendableMessage], companion: model.companion)
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    let receivedMessage = MessageModel(role: "assistant", content: value.message)
                    model.messages.append(receivedMessage)
//                    self.chatsStorage.updateChat(chat: model)
                    return .receiveComplete(model) }
                .catch { error in
                    return Just(.errorReceiveMessage(error: error))
                }
                .eraseToAnyPublisher()
        case .receiveComplete(let model):
            state.isMessageReceiving = false
            state.chat.value = model
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
            guard let firstIndex = state.chat.value.messages.firstIndex(of: message) else { return .none }
            state.chat.value.messages.remove(at: firstIndex)
        case .onViewAppear:
            state.navigationTitle = state.chat.value.companion.name
        }
        
        return .none
    }
    deinit {
        print("DEINIT CHAT VIEW STORE")
    }
}
