//
//  SongSearchRepository.swift
//  MoisesSearch
//

import Foundation

struct SongSearchPage: Equatable, Sendable {
    let items: [SongListItem]
    /// Total matches reported by the API for this query (not only this page).
    let totalResultCount: Int
    let limit: Int
    let offset: Int

    var hasMorePages: Bool {
        offset + items.count < totalResultCount
    }
}

protocol SongSearchRepository {
    func searchSongs(query: String, limit: Int, offset: Int) async throws -> SongSearchPage
}
