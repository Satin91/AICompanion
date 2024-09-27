//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI
import OpenAI
import SwiftAnthropic


struct EventMessage: Codable {
    let model: String
    let messages: [Message]
}

struct Message: Codable {
    let role, content: String
}


final class MainViewModel: ObservableObject {

    @Published var message: String = ""
    
    
    func sendMessage() async {
        let url = URL(string: "https://gptunnel.ru/v1/chat/completions")!
        var request = URLRequest(url: url)
        //"gpt-3.5-turbo"
//            .init(role: "system", content: "My name is Robert.")
        let message = EventMessage(model: "gpt-4o-mini", messages: [ .init(role: "user", content: "Как меня зовут ?") ])
        request.httpMethod = "POST"
        request.addValue("shds-WJN3qNCLcxD3mOXuhchwGOVkF90", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let jsonData = try! JSONEncoder().encode(message)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let statusCode = response as! HTTPURLResponse
            if statusCode.statusCode == 402 {
                print("ОПЛАТИ")
            } else {
                print("Data", String(data: data!, encoding: .utf8 ))
            }
        }
        .resume()
    }
}
