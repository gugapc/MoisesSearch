//
//  APIClientTestSupport.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation
@testable import MoisesSearch

struct TestItem: Decodable, Equatable {
    let id: Int
    let title: String
    let author: String
}

// MARK: - URLSessionMock

class URLSessionMock: URLSessionProtocol {
    var data: Data?
    var error: (any Error)?
    var response: URLResponse?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error {
            throw error
        } else {
            (data ?? Data(), response ?? URLResponse())
        }
    }
}

