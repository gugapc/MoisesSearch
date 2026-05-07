//
//  TargetType.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 28/04/26.
//

import Foundation

protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var header: [String: String] { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
    var method: HTTPMethod { get }
}

extension TargetType {
    var baseURL: URL { URL(string: "https://itunes.apple.com")! }
    var header: [String: String] { [:] }
    var body: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var method: HTTPMethod { .get }
}
