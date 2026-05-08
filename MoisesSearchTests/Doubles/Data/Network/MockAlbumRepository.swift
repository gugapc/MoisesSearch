//
//  MockAlbumRepository.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation
@testable import MoisesSearch

struct MockAlbumRepository: AlbumRepository {
    var album: AlbumDetail?
    var error: (any Error)?

    func fetchAlbum(collectionId: Int) async throws -> AlbumDetail {
        if let error {
            throw error
        }
        guard let album else {
            throw APIError.invalidRequest
        }
        return album
    }
}
