//
//  AppSettingsInteractor.swift
//  AICompanion
//
//  Created by Артур Кулик on 18.10.2024.
//

import Foundation
import Combine
import SwiftUI

final class AppSettingsInteractor: ObservableObject {
    private let storageManager = StorageRepository()
    private let colorSchemeKey = "ColorScheme"
    private var cancellable = Set<AnyCancellable>()
    
    var colorScheme = CurrentValueSubject<ColorScheme, Never>(.light)
    
    init() {
        fetch()
        subscribe()
    }
    
    func subscribe() {
        colorScheme.sink { [unowned self] value in
            objectWillChange.send()
            let boolean = value == .light ? true : false
            do {
                print("Saving value \(boolean) to storage")
                print("color scheme  \(colorScheme.value) ")
                try storageManager.saveObject(object: boolean, for: colorSchemeKey)
            } catch {
                fatalError("error save color scheme")
            }
        }
        .store(in: &cancellable)
    }
    
    private func fetch() {
        guard let colorScheme = storageManager.fetchObject(item: Bool.self, for: colorSchemeKey) else {
            colorScheme.send(.dark)
            return
        }
        
        self.colorScheme.send(colorScheme == true ? .light : .dark)
        
    }
    
}
