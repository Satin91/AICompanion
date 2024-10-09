//
//  StorageService.swift
//  AICompanion
//
//  Created by Артур Кулик on 07.10.2024.
//

import Combine
import Foundation

protocol ChatsStorageInteractorProtocol {
    var chats: CurrentValueSubject<[ChatModel], Never> { get }
    func createChat(chat: ChatModel)
    func updateChat(chat: ChatModel)
    func deleteChat(chat: ChatModel)
}

protocol BalanceStorageServiceProtocol {
    func fetchBalance()
    func saveBalance()
}



final class ChatsStorageInteractor: ObservableObject, ChatsStorageInteractorProtocol {
    let storageManager = StorageRepository()
    var chats = CurrentValueSubject<[ChatModel], Never>([])
//    var balance = CurrentValueSubject<Double, Never>(0)
    private let chatsKey = "Chats"
    
    init() {
        fetchChats()
    }
    
    func createChat(chat: ChatModel) {
        do {
            let allChatsData = storageManager.fetchObject(for: chatsKey)
            
            if allChatsData == nil {
                try storageManager.saveObject(object: [chat], for: chatsKey)
                chats.send([chat])
            } else {
                var allChats = chats.value
                allChats.append(chat)
                try storageManager.saveObject(object: allChats, for: chatsKey)
                chats.send(allChats)
            }
        } catch {
            print("Error of creating chat \(error.localizedDescription)")
        }
    }
    
    func updateChat(chat: ChatModel) {
        var chats = self.chats.value
        for (index, element) in chats.enumerated() {
            if element.id == chat.id {
                chats[index].messages = chat.messages
                do {
                    try storageManager.saveObject(object: chats, for: chatsKey)
                    self.chats.send(chats)
                } catch {
                    print("can't save chats \(error.localizedDescription)")
                }
                break
            }
        }
    }
    
    func deleteChat(chat: ChatModel) {
        guard let chatIndex = chats.value.firstIndex(of: chat) else { return }
        chats.value.remove(at: chatIndex)
        do {
            try storageManager.saveObject(object: chats.value, for: chatsKey)
            chats.update()
        } catch {
            print("Error delete chat")
        }
    }
    
    private func fetchChats() {
        guard let chatsData = storageManager.fetchObject(for: chatsKey) else {
            chats.send([])
            return
        }
        
        do {
            let chatsArray = try JSONDecoder().decode([ChatModel].self, from: chatsData)
            chats.send(chatsArray)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension CurrentValueSubject {
    func update() {
        self.send(self.value)
    }
}
