//
//  StorageManager.swift
//  AICompanion
//
//  Created by Артур Кулик on 29.09.2024.
//

import Foundation
import CoreData
import Combine


final class StorageManager {
    private var defaults = UserDefaults.standard
    
    var chats = CurrentValueSubject<[ChatModel], Never>([])
    var balance = CurrentValueSubject<Double, Never>(0)
    
    init() {
        initialState()
    }
    
    func initialState() {
        getChats()
        getBalance()
    }
    
    func getChats() {
        do {
            guard let data = defaults.data(forKey: "Chats") else { return }
            let decoded = try JSONDecoder().decode([ChatModel].self, from: data)
            chats.send(decoded)
            print("Decoded chat \(decoded)")
        } catch {
            print("Error get chats, chats is absent!")
        }
    }
    
    func saveChat(chat: ChatModel) {
        var chats = self.chats.value
        for (index, element) in chats.enumerated() {
            if element.id == chat.id {
                chats[index].messages = chat.messages
                do {
                    let data = try JSONEncoder().encode(chats)
                    defaults.set(data, forKey: "Chats")
                    self.chats.send(chats)
                } catch {
                    print("can't save chats \(error.localizedDescription)")
                }
                break
            }
        }
    }
    
    func deleteChat(model: ChatModel) {
        guard let chatIndex = chats.value.firstIndex(of: model) else { return }
        chats.value.remove(at: chatIndex)
        do {
            let data = try JSONEncoder().encode(chats.value)
            defaults.set(data, forKey: "Chats")
            chats.send(chats.value)
        } catch {
            print("Error delete chat")
        }
    }
    
    func createChat(chatModel: ChatModel) {
        do {
            let allChatsData = defaults.data(forKey: "Chats")
            
            if allChatsData == nil {
                
                let data = try JSONEncoder().encode([chatModel])
                defaults.set(data, forKey: "Chats")
                chats.send([chatModel])
            } else {
                var allChatsDecoded = try! JSONDecoder().decode([ChatModel].self, from: allChatsData ?? Data())
                allChatsDecoded.append(chatModel)
                let data = try JSONEncoder().encode(allChatsDecoded)
                defaults.set(data, forKey: "Chats")
                chats.send(allChatsDecoded)
            }
        } catch {
            print("Error encode \(error.localizedDescription)")
        }
    }
    
    func getBalance() {
        let balance = defaults.double(forKey: "balance")
        self.balance.send(balance)
    }
    
    func saveBalance(balance: Double) {
        print("new balance\(balance)")
        self.balance.send(balance)
        defaults.setValue(balance, forKey: "balance")
    }
}
