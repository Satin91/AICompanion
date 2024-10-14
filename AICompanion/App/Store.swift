//
//  Store.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import Foundation
import Combine

typealias Reducer<State, Action> = (inout State, Action) -> Void
typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

protocol ViewStore: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get set }
    var middlewares: [Middleware<State, Action>] { get }
    
    init(state: State, middlewares: [Middleware<State, Action>])
    
    func reduce(state: inout State, action: Action) -> Void
}

final class CombineStoreCancellable {
    static var cancellable = Set<AnyCancellable>()
}

extension ViewStore {
    func dispatch(_ action: Action) {
        reduce(state: &state, action: action)
        
        for middleware in middlewares {
            guard let middleware = middleware(state, action) else { break }
            middleware
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: dispatch)
                .store(in: &CombineStoreCancellable.cancellable)
        }
        
    }
}
//
//final class Store<State, Action>: ObservableObject {
//    @Published private(set) var state: State
//    let middlewares: [Middleware<State, Action>]
//    let reducer: Reducer<State, Action>
//    
//    private var cancellable = Set<AnyCancellable>()
//    
//    init(state: State, reducer: @escaping Reducer<State, Action>, middlewares: [Middleware<State, Action>] = []) {
//        self.state = state
//        self.reducer = reducer
//        self.middlewares = middlewares
//    }
//    
//    func dispatch(_ action: Action) {
//        reducer(&state, action)
//        
//        for middleware in middlewares {
//            guard let middleware = middleware(state, action) else { break }
//            
//            middleware
//                .receive(on: DispatchQueue.main)
//                .sink(receiveValue: dispatch)
//                .store(in: &cancellable)
//        }
//        
//    }
//}
