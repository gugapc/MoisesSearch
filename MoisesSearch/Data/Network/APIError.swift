//
//  APIError.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidRequest
    case invalidResponse(Int)
    case decodeError(Error)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidRequest, .invalidRequest):
            return true
        case let (.invalidResponse(codeL), .invalidResponse(codeR)):
            return codeL == codeR
        case let (.decodeError(errorL), .decodeError(errorR)):
            let lhsError = errorL as NSError
            let rhsError = errorR as NSError
            return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        default:
            return false
        }
    }
}
