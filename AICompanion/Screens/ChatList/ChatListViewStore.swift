//
//  ChatListViewStore.swift
//  AICompanion
//
//  Created by Артур Кулик on 14.10.2024.
//

import Foundation
import Combine

struct ChatListState {
    var balance: Double
    var chats = CurrentValueSubject<[ChatModelObserver], Never>([])
    var selectedCompanion = CompanionType.gpt4o
}

enum ChatListActions {
    case getBalance
    case receiveBalance(balance: Double)
    case createChat(name: String)
    case deleteChat(model: ChatModel)
    case selectCompanion(_ companion: CompanionType)
    case onViewApear
}

class ChatListViewStore: ViewStore {
    @Published var state: ChatListState
    var chatsStorage: ChatsStorageInteractorProtocol
    var networkService = ChatsNetworkService()
    
    init(state: ChatListState, chatsStorage: ChatsStorageInteractorProtocol) {
        self.state = state
        self.chatsStorage = chatsStorage
    }

    func reduce(state: inout ChatListState, action: ChatListActions) -> Effect<ChatListActions> {
        switch action {
        case .getBalance:
            return self.networkService
                .getBalance()
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    .receiveBalance(balance: value.balance)
                }
                .catch { error in
                    Just(.receiveBalance(balance: 0))
                }
                .eraseToAnyPublisher()
        case .selectCompanion(let companion):
            state.selectedCompanion = companion
        case .receiveBalance(balance: let balance): 
            state.balance = balance
        case .onViewApear:
            state.chats = chatsStorage.chats
            return Just(.getBalance).eraseToAnyPublisher()
        case .createChat(name: let name):
            let chat = ChatModel(id: UUID().uuidString, companion: state.selectedCompanion, name: name, messages: []).observer
            state.chats.value.append(chat)
        case .deleteChat(model: let model):
            guard let chatIndex = state.chats.value.firstIndex(of: model.observer ) else { return .none}
            state.chats.value.remove(at: chatIndex)
        }
        return .none
    }
}
