//
//  PublishersError.swift
//  AICompanion
//
//  Created by Артур Кулик on 19.10.2024.
//

import Combine

extension Subscribers.Completion {
    var error: Failure? {
        switch self {
        case let .failure(error): return error
        default: return nil
        }
    }
}
