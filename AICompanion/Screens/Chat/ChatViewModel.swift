//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import Combine
import CoreData
//struct

final class ChatViewModel: ObservableObject {
    var networkService = NetworkService()
    var cancellable = Set<AnyCancellable>()
    
    var chatsService: ChatsStorageInteractorProtocol
    
    @Published var isCompanionThinking = false
    @Published var chatModel: ChatModel
    @Published var isMemoryEnabled = false
    @Published var isScrollViewAnimate = false
    
    init(model: ChatModel, chatsService: ChatsStorageInteractorProtocol) {
        self.chatModel = model
        self.chatsService = chatsService
    }
    
    
    func send(message: String) {
        sendMessages(text: message)
    }
    
    func sendMessages(text: String) {
        chatModel.messages.append(MessageModel(role: "user", content: text) )
        self.animateScrollView()
        
        let messages = chatModel.messages
        let message: [MessageModel] = [MessageModel(role: "user", content: text)]
        
        isCompanionThinking = true
        networkService.sendMessage(message: isMemoryEnabled ? messages : message, companion: chatModel.companion)
            .sink(receiveCompletion: { compl in
                self.isCompanionThinking = false
            }, receiveValue: { value in
                print("received Value", value)
                self.chatModel.messages.append(MessageModel(role: "assistant", content: value.message) )
                self.animateScrollView()
                self.chatsService.updateChat(chat: self.chatModel)
                self.getBalance()
                
                
            })
            .store(in: &cancellable)
    }
    
    func animateScrollView() {
        isScrollViewAnimate.toggle()
    }
    
    func deleteMessage(message: MessageModel) {
        guard let firstIndex = chatModel.messages.firstIndex(of: message) else { return }
        chatModel.messages.remove(at: firstIndex)
        chatsService.updateChat(chat: chatModel)
    }
    
    func getBalance() {
        sends(value: chatModel.messages.first)
        networkService.getBalance().sink { _ in
        } receiveValue: { balance in
            //            self.storageManager.saveBalance(balance: balance.balance)
        }
        .store(in: &cancellable)
    }
    
    func sends<T: Decodable>(value: T) {
        
    }
}
