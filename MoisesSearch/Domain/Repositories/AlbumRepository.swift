//
//  AlbumRepository.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation

protocol AlbumRepository: Sendable {
    func fetchAlbum(collectionId: Int) async throws -> AlbumDetail
}

/// No-op repository for previews / tests where a real network round-trip isn't desired.
struct EmptyAlbumRepository: AlbumRepository {
    func fetchAlbum(collectionId: Int) async throws -> AlbumDetail {
        throw APIError.invalidRequest
    }
}
