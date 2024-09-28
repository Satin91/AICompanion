//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import Combine

//struct

final class ChatViewModel: ObservableObject {

    @Published var messages: [Message] = []
    var networkService = NetworkService()
    var cancellable = Set<AnyCancellable>()
    
    func sendMessage(text: String) {
        messages.append(Message(role: "user", content: text))
        networkService.sendMessage(message: text).sink { compl in
            print("completion", compl)
//            self.message = ""
        } receiveValue: { value in
            print("Пришло значение:", value.model)
            self.messages.append(value.choices.first!.message)
            
        }
        .store(in: &cancellable)
    }
}
