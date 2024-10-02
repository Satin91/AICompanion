//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import Combine

final class ChatListViewModel: ObservableObject {
    
    let storageManager: StorageManager
    var networkService = NetworkService()
    
    @Published var chats: [ChatModel] = []
    var selectedChat = ChatModel(companion: .claude3_5_sonnet, name: "", messages: [])
    
    var cancellable = Set<AnyCancellable>()
    @Published private(set) var balance: Double = 0
    
    //Navigation
    @Published var isShowChatView = false
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
        initialState()
        assign()
//        subscribe()
        
    }
    
    func initialState() {
        chats = storageManager.chats.value
        getBalance()
    }
    
    func assign() {
        storageManager.chats
            .assign(to: &$chats)
        storageManager.balance
            .assign(to: &$balance)
    }
    
    func showChatView(model: ChatModel) {
        selectedChat = model
        isShowChatView = true
    }
    
    func createChat(name: String) {
        storageManager.createChat(name: name)
        print(chats.count)
    }
    
    func getBalance() {
        networkService.getBalance().sink { _ in
        } receiveValue: { value in
            print("get balance \(value.balance)")
            self.storageManager.saveBalance(balance: value.balance)
        }
        .store(in: &cancellable)

    }
}
