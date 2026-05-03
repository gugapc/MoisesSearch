//
//  ITunesSearchTarget.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import Foundation

enum ITunesSearchTarget: TargetType {
    case songSearch(term: String, limit: Int)
    case albumLookup(collectionId: Int)

    var path: String {
        switch self {
        case .songSearch:
            "/search"
        case .albumLookup:
            "/lookup"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .songSearch(term, limit):
            [
                URLQueryItem(name: "term", value: term),
                URLQueryItem(name: "media", value: "music"),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        case let .albumLookup(collectionId):
            [
                URLQueryItem(name: "id", value: String(collectionId)),
                URLQueryItem(name: "entity", value: "song"),
            ]
        }
    }
}
