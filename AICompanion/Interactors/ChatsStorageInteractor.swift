//
//  StorageService.swift
//  AICompanion
//
//  Created by Артур Кулик on 07.10.2024.
//

import Combine
import Foundation


protocol ChatsStorageInteractorProtocol {
    var chats: CurrentValueSubject<[ChatModelObserver], Never> { get }
    //    func createChat(chat: ChatModel)
    //    func updateChat(chat: ChatModel)
    //    func deleteChat(chat: ChatModel)
}

protocol BalanceStorageServiceProtocol {
    func fetchBalance()
    func saveBalance()
}


typealias ChatModelObserver = CurrentValueSubject<ChatModel, Never>


final class ChatsStorageInteractor: ObservableObject, ChatsStorageInteractorProtocol {
    let storageManager = StorageRepository()
    var chats = CurrentValueSubject<[ChatModelObserver], Never>([])
    private let chatsKey = "Chats"
    private var cancellable = Set<AnyCancellable>()
    
    
    init() {
        fetchChats()
        subscribe()
    }
    
    private func subscribe() {
        chats
            .subscribe(on: DispatchQueue.main)
            .sink { [unowned self] chats in
                subscribeForChild()
                updateChats()
            }
            .store(in: &cancellable)
        
        subscribeForChild()
    }
    
    private func subscribeForChild() {
        for chat in chats.value {
            chat
                .subscribe(on: DispatchQueue.main)
                .sink { [unowned self] value in
                    updateChats()
                }
                .store(in: &cancellable)
        }
    }
    
    private func updateChats() {
        do {
            let chatsModel: [ChatModel] = self.chats.value.map { ChatModel(id: $0.value.id, companion: $0.value.companion, name: $0.value.name, messages: $0.value.messages) }
            try self.storageManager.saveObject(object: chatsModel, for: self.chatsKey)
        } catch {
            print("Error save chats")
        }
    }
    //
    //    func createChat(chat: ChatModel) {
    ////        if chats.value.isEmpty {
    ////            chats.send([chat])
    ////        } else {
    ////            chats.value.append(chat)
    ////        }
    //    }
    //
    //    func updateChat(chat: ChatModel) {
    //        var chats = self.chats.value
    //        for (index, element) in chats.enumerated() {
    ////            if element.id == chat.id {
    ////                chats[index] = chat
    ////                self.chats.send(chats)
    //                break
    ////            }
    //        }
    //    }
    //
    //    func deleteChat(chat: ChatModel) {
    ////        guard let chatIndex = chats.value.firstIndex(of: chat) else { return }
    ////        chats.value.remove(at: chatIndex)
    //    }
    
    private func fetchChats() {
        guard let chatsData = storageManager.fetchObject(for: chatsKey) else {
            chats.send([])
            return
        }
        
        do {
            let chatsArray = try JSONDecoder().decode([ChatModel].self, from: chatsData)
            let chatsar = chatsArray.map { ChatModelObserver($0) }
            chats.send(chatsar)
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

extension ChatModelObserver: Equatable {
    public static func == (lhs: CurrentValueSubject<Output, Failure>, rhs: CurrentValueSubject<Output, Failure>) -> Bool {
        lhs.value.id == rhs.value.id
    }
}
