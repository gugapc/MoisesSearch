//
//  MockSongSearchRepository.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 02/05/26.
//

import Foundation
@testable import MoisesSearch

struct MockSongSearchRepository: SongSearchRepository {
    var page: SongSearchPage
    var error: (any Error)?

    func searchSongs(query: String, limit: Int) async throws -> SongSearchPage {
        if let error {
            throw error
        }
        return page
    }
}
