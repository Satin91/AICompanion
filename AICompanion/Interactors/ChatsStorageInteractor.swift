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
}

protocol BalanceStorageServiceProtocol {
    func fetchBalance()
    func saveBalance()
}


typealias ChatModelObserver = CurrentValueSubject<ChatModel, Never>


final class ChatsStorageInteractor: ObservableObject, ChatsStorageInteractorProtocol {
    let storageManager = StorageRepository()
    var chats = CurrentValueSubject<[ChatModelObserver], Never>([])
    private let backgroundQueue = DispatchQueue(label: "com.ai.chatsbackgroundqueue", qos: .background)
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
        backgroundQueue.async {
            do {
                let chatsModel: [ChatModel] = self.chats.value.map { ChatModel(id: $0.value.id, companion: $0.value.companion, name: $0.value.name, messages: $0.value.messages) }
                try self.storageManager.saveObject(object: chatsModel, for: self.chatsKey)
            } catch {
                print("Error save chats")
            }
        }
    }

    private func fetchChats() {
        guard let chatsData = storageManager.fetchObject(item: [ChatModel].self, for: chatsKey) else {
            chats.send([])
            return
        }
        do {
            let chatsar = chatsData.map { ChatModelObserver($0) }
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
