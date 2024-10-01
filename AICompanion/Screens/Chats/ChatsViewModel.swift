//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import Combine

final class ChatsViewModel: ObservableObject {
    
    let storageManager: StorageManager
    var networkService = NetworkService()
    
    @Published var chats: [ChatModel] = []
    var cancellable = Set<AnyCancellable>()
    var balance: String = ""
    
    //Navigation
    @Published var isShowChatView = false
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
        initialState()
        assign()
        getBalance()
    }
    
    func initialState() {
        chats = storageManager.chats.value
    }
    
    func assign() {
        storageManager.chats
            .assign(to: &$chats)
    }
    
    func showChatView(model: ChatModel) {
        isShowChatView = true
    }
    
    func createChat(name: String) {
        storageManager.createChat(name: name)
        print(chats.count)
    }
    
    func getBalance() {
        networkService.getBalance().sink { completion in
            
        } receiveValue: { value in
//            balance
            print("get balance \(value.balance)")
        }
        .store(in: &cancellable)

    }
}
