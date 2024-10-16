//
//  NetworkManager.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation
import Combine

enum NetworkError: Error {
    case notFound
    case cantDecodeThis(text: String)
    case serverError(code: Int, text: String)
}

final class NetworkManager {
    func request<T: Decodable>(request: URLRequest) -> AnyPublisher<T, NetworkError> {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 45
        let urlSession = URLSession(configuration: config)
        return urlSession.dataTaskPublisher(for: request)
            .tryMap { output in
                print(String(data: output.data, encoding: .utf8) )
                guard let response = output.response as? HTTPURLResponse else { throw NetworkError.serverError(code: 0, text: "Server error") }
                guard !(400...499).contains(response.statusCode) else { throw NetworkError.notFound }
                guard !(500...599).contains(response.statusCode) else { throw NetworkError.serverError(code: response.statusCode, text: "Сервер недоступен, возможно он перегружен") }
                guard (200...299).contains(response.statusCode) else { throw NetworkError.serverError(code: response.statusCode, text: "Bad status code") }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                return error as? NetworkError ?? NetworkError.cantDecodeThis(text: error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
