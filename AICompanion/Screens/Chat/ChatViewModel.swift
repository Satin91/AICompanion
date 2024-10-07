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
    
    init(model: ChatModel, chatsService: ChatsStorageInteractorProtocol) {
        self.chatModel = model
        self.chatsService = chatsService
    }
    
    
    func send(message: String) {
        isMemoryEnabled ? sendMessages(text: message) : sendMessage(text: message)
    }
    
    func sendMessages(text: String) {
        chatModel.messages.append(MessageModel(role: "user", content: text) )
        
        
        let messages = chatModel.messages.map { Message(role: $0.role, content: $0.content) }
        isCompanionThinking = true
        networkService.sendMessages(messages: messages, companion: chatModel.companion)
            .sink(receiveCompletion: { compl in
                self.isCompanionThinking = false
//
//                switch compl {
//                case .finished:
//                    print("____")
//                case .failure(let failure):
//                    print("failure receive message \(failure)")
//                }
        }, receiveValue: { value in
            print("received Value", value.choices.first?.message.content ?? "")
            self.chatModel.messages.append(MessageModel(role: value.choices.first?.message.role ?? "", content: value.choices.first?.message.content ?? "") )
            self.chatsService.updateChat(chat: self.chatModel)
            self.getBalance()
            
            
        })
            .store(in: &cancellable)
    }
    
    func sendMessage(text: String) {
        isCompanionThinking = true
        chatModel.messages.append(MessageModel(role: "user", content: text) )
        networkService.sendMessage(message: text, companion: chatModel.companion).sink { compl in
            self.isCompanionThinking = false
//            
//            switch compl {
//            case .failure(let error):
//                switch error {
//                case let .serverError(code: code, text: text):
//                    print("Network error \(code), text \(text)")
//                default :
//                    break
//                }
//            default:
//                break
//            }
            
        } receiveValue: { value in
            print("Пришло значение:", value.choices.first?.message)
            self.chatModel.messages.append(MessageModel(role: value.choices.first?.message.role ?? "", content: value.choices.first?.message.content ?? "") )
            self.chatsService.updateChat(chat: self.chatModel)
            
            self.getBalance()
        }
        .store(in: &cancellable)
    }
    
    func getBalance() {
        networkService.getBalance().sink { _ in
        } receiveValue: { balance in
//            self.storageManager.saveBalance(balance: balance.balance)
        }
        .store(in: &cancellable)
    }
}
