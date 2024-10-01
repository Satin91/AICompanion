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
    
    init() {
        getChats()
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
    
    func createChat(name: String) {

        do {
            
            let allChatsData = defaults.data(forKey: "Chats")
            let chatModel = ChatModel(name: name, messages: [])
            
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
    
    
}

//class StorageManager: NSObject, ObservableObject {
//    static let container: NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
//    lazy var context: NSManagedObjectContext = StorageManager.container.viewContext
//    
//    @Published var messages: [MessageModel] = []
//    @Published var chats: [ChatModel] = []
//    
//    
//    override init() {
//        super.init()
//        StorageManager.container.loadPersistentStores { _, _ in }
////        fetchMessagesItems()
//        fetchChatsItems()
//    }
//    
//    func createChat(name: String) {
////        createMock()
//        let chat = ChatModel(context: context)
//        chat.name = "Ещё одно имя"
//        let message = MessageModel(context: context)
//        message.content = "some message"
//        message.role = "user"
//        chat.messages = NSSet(array: [message])
//        
//        saveAndFetch()
//    }
//    
//    func createMock() {
//        let chat = ChatModel(context: context)
//        chat.name = "Пустой чат!"
//        saveAndFetch()
//    }
//    
//    func addMessageToStorage(role: String, content: String) {
//        let newMessage = MessageModel(context: context)
//        newMessage.role = role
//        newMessage.content = content
//        saveAndFetch()
//    }
//    
//    
//    func fetchChatsItems() {
//        do {
//            var request = ChatModel.fetchRequest()
//            
//            chats = try context.fetch(request)
//            let messages: [MessageModel] = Array(chats.first!.messages!.allObjects) as? [MessageModel] ?? []
//            self.messages = messages
//            
//            print("fetch data \(chats) , messages \(Array(chats.first!.messages!.allObjects) as? [MessageModel])")
//        } catch {
//            print("Error Fetching Shopping Cart: \(error.localizedDescription)")
//        }
//    }
//    
////    func fetchMessagesItems() {
////        do {
////            let request = MessageModel.fetchRequest()
////            messages = try context.fetch(request)
////        } catch {
////            print("Error Fetching Shopping Cart: \(error.localizedDescription)")
////        }
////    }
//    
//    func saveContext() {
//        do {
//            try context.save()
//        } catch {
//            print("Error Saving Messages: \(error.localizedDescription)")
//        }
//    }
//    
//    func saveAndFetch() {
//        do {
//            try context.save()
////            fetchMessagesItems()
//            fetchChatsItems()
//        } catch {
//            print("Error Saving Shopping Cart: \(error.localizedDescription)")
//        }
//    }
//}
