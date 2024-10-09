//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import Combine

final class ChatListViewModel: ObservableObject {
    
    var chatsService: ChatsStorageInteractorProtocol
    var networkService = NetworkService()
    
    @Published var chats: [ChatModel] = []
    var selectedChat = ChatModel(companion: .gpt4o , name: "", messages: [])
    
    @Published var selectedCompanion: CompanionType = .gpt4o
    
    var cancellable = Set<AnyCancellable>()
    
    @Published private(set) var balance: Double = 0
    
    //Navigation
    @Published var isShowChatView = false
    
    init(chatsService: ChatsStorageInteractorProtocol) {
        self.chatsService = chatsService
        initialState()
        assign()
    }
    
    func initialState() {
        chats = chatsService.chats.value
        getBalance()
    }
    
    func assign() {
        chatsService.chats
            .assign(to: &$chats)
//        storageManager.balance
//            .assign(to: &$balance)
    }
    
    func showChatView(model: ChatModel) {
        selectedChat = model
        isShowChatView = true
    }
    
    func createChat(name: String) {
        let chat = ChatModel(companion: selectedCompanion, name: name, messages: [])
        chatsService.createChat(chat: chat)
    }
    
    func getBalance() {
        networkService.getBalance().sink { _ in
        } receiveValue: { value in
            self.balance = value.balance
        }
        .store(in: &cancellable)
    }
    
    func deleteChat(model: ChatModel) {
        chatsService.deleteChat(chat: model)
    }
    
    // Bottom Sheet
    func selectCompanion(_ companion: CompanionType) {
        selectedCompanion = companion
    }
}
