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
    var storageManager: StorageManager
    
    @Published var chatModel: ChatModel
    
    init(model: ChatModel, storageManager: StorageManager) {
        self.chatModel = model
        self.storageManager = storageManager
    }
    
    func sendMessage(text: String) {
        chatModel.messages.append(MessageModel(role: "user", content: text) )
//        self.storageManager.saveChat(chat: self.chatModel)
        networkService.sendMessage(message: text).sink { compl in
            switch compl {
            case .failure(let error):
                switch error {
                case let .serverError(code: code, text: text):
                    print("Network error \(code), text \(text)")
                default :
                    break
                }
            default:
                break
            }
            
        } receiveValue: { value in
            print("Пришло значение:", value.model)
            self.chatModel.messages.append(MessageModel(role: value.choices.first?.message.role ?? "", content: value.choices.first?.message.content ?? "") )
            self.storageManager.saveChat(chat: self.chatModel)
        }
        
        .store(in: &cancellable)
    }
}