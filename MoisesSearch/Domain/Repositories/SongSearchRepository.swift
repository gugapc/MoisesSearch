//
//  SongSearchRepository.swift
//  MoisesSearch
//

import Foundation

struct SongSearchPage: Equatable, Sendable {
    let items: [SongListItem]
    /// Count reported with this response (iTunes `resultCount` = size of `results` in that payload).
    let resultCount: Int
}

protocol SongSearchRepository {
    func searchSongs(query: String, limit: Int) async throws -> SongSearchPage
}
