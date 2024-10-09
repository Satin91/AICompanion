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
//        sendMessage(text: message)
    }
    
    func sendMessages(text: String) {
        chatModel.messages.append(MessageModel(role: "user", content: text) )
        self.animateScrollView()
        
        let messages = chatModel.messages
        let message: [MessageModel] = [MessageModel(role: "user", content: text)]
        
        isCompanionThinking = true
        networkService.sendMessage(message: isMemoryEnabled ? messages : message, companion: chatModel.companion)
//        networkService.sendMessage(message: isMemoryEnabled ? message : messages, companion: chatModel.companion)
            .sink(receiveCompletion: { compl in
                self.isCompanionThinking = false
            }, receiveValue: { value in
                print("received Value", value.message)
                self.chatModel.messages.append(MessageModel(role: value.choices.first?.message.role ?? "", content: value.message) )
                self.animateScrollView()
                self.chatsService.updateChat(chat: self.chatModel)
                self.getBalance()
                
                
            })
            .store(in: &cancellable)
    }
    
//    func sendMessage(text: String) {
//        isCompanionThinking = true
//        
//        self.animateScrollView()
//        let singleMessage = MessageModel(role: "user", content: text)
//        var any: Any = isMemoryEnabled ? chatModel.messages : singleMessage
//        
//        
//        chatModel.messages.append(singleMessage)
//        
//        
//        networkService.sendMessage(message: any as! [MessageModel], companion: chatModel.companion).sink { compl in
//            self.isCompanionThinking = false
//        } receiveValue: { value in
//            print("Пришло значение:", value.message)
//            self.chatModel.messages.append(MessageModel(role: value.choices.first?.message.role ?? "", content: value.message) )
//            self.animateScrollView()
//            self.chatsService.updateChat(chat: self.chatModel)
//            self.getBalance()
//        }
//        .store(in: &cancellable)
//    }
    
    func animateScrollView() {
        isScrollViewAnimate.toggle()
    }
    
    func getBalance() {
        networkService.getBalance().sink { _ in
        } receiveValue: { balance in
            //            self.storageManager.saveBalance(balance: balance.balance)
        }
        .store(in: &cancellable)
    }
}
