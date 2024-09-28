//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import Combine

//struct

final class MainViewModel: ObservableObject {

    @Published var message: String = ""
    @Published var messages: [Message] = []
    var networkService = NetworkService()
    var cancellable = Set<AnyCancellable>()
    
    func sendMessage() {
        messages.append(Message(role: "user", content: message) )
        networkService.sendMessage(message: message).sink { compl in
            print("completion", compl)
            self.message = ""
        } receiveValue: { value in
            print("Пришло значение:", value)
            self.messages.append(value.choices.first!.message)
            
        }
        .store(in: &cancellable)
    }
}
