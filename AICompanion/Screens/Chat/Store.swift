//
//  Store.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import Foundation
import Combine

typealias Reducer<State, Action> = (inout State, Action) -> Void

final class Store<State, Action>: ObservableObject {
    @Published private(set) var state: State
    let middlewares: [Middleware<State, Action>]
    let reducer: Reducer<State, Action>
    
    private var cancellable = Set<AnyCancellable>()
    
    init(state: State, reducer: @escaping Reducer<State, Action>, middlewares: [Middleware<State, Action>] = []) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }
    
    func dispatch(_ action: Action) {
        reducer(&state, action)
        
        for middleware in middlewares {
            guard let middleware = middleware(state, action) else { break }
            
            middleware
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: dispatch)
                .store(in: &cancellable)
        }
        
    }
}
