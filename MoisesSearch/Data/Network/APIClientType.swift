//
//  APIClientType.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation

protocol APIClientType {
    func request<T: Decodable>(_ target: any TargetType) async throws -> T
}

final class APIClient: APIClientType {
    private var decoder: JSONDecoder
    private var session: any URLSessionProtocol
    
    init(decoder: JSONDecoder = JSONDecoder(),
         session: any URLSessionProtocol = URLSession.shared) {
        self.decoder = decoder
        self.session = session
    }
    
    func request<T: Decodable>(_ target: any TargetType) async throws -> T {
        var components = URLComponents(string: target.baseURL.absoluteString)!
        components.path = target.path
        components.queryItems = target.queryItems
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.header
        request.httpBody = target.body
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.invalidRequest
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse(-1)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodeError(error)
        }
    }
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
