//
//  ITunesAlbumRepository.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 07/05/26.
//

import Foundation

/// iTunes Search lookup implementation (replaceable via `AlbumRepository`).
final class ITunesAlbumRepository: AlbumRepository {
    private let client: any APIClientType

    init(client: any APIClientType) {
        self.client = client
    }

    func fetchAlbum(collectionId: Int) async throws -> AlbumDetail {
        let target = ITunesSearchTarget.albumLookup(collectionId: collectionId)
        let dto: ITunesAlbumLookupResponseDTO = try await client.request(target)
        return try dto.toAlbumDetail()
    }
}
