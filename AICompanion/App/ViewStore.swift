//
//  Store.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import Foundation
import Combine


typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?
typealias Effect<State> = AnyPublisher<State, Never>?

protocol ViewStore: AnyObject, ObservableObject {
    
    associatedtype State
    associatedtype Action
    
    var state: State { get set }
    
    func reduce(state: inout State, action: Action) -> Effect<Action>
}

extension ViewStore {
    
    func dispatch(_ action: Action) {
        reduce(state: &state, action: action)?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: dispatch)
            .store(in: &ViewStoreCancellable.cancellable)
    }
}

fileprivate class ViewStoreCancellable {
    static var cancellable = Set<AnyCancellable>()
}
