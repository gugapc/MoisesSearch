//
//  ITunesSongSearchRepository.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import Foundation

/// iTunes Search API implementation (replaceable via `SongSearchRepository`).
final class ITunesSongSearchRepository: SongSearchRepository {
    private let client: any APIClientType

    init(client: any APIClientType) {
        self.client = client
    }

    func searchSongs(query: String, limit: Int, offset: Int) async throws -> SongSearchPage {
        let target = ITunesSearchTarget.songSearch(term: query, limit: limit, offset: offset)
        let dto: ITunesSearchResponseDTO = try await client.request(target)
        let items = dto.results.map { $0.toSongListItem() }
        return SongSearchPage(
            items: items,
            totalResultCount: dto.resultCount,
            limit: limit,
            offset: offset
        )
    }
}
