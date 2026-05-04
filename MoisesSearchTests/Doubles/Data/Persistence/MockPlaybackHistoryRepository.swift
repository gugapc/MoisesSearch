//
//  MockPlaybackHistoryRepository.swift
//  MoisesSearchTests
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation
@testable import MoisesSearch

@MainActor
final class MockPlaybackHistoryRepository: PlaybackHistoryRepository {
    private(set) var recentToReturn: [SongListItem]
    private(set) var recordCalls: [(SongListItem, Date)] = []
    private let shouldThrowOnRecent: Bool

    init(recentToReturn: [SongListItem] = [], shouldThrowOnRecent: Bool = false) {
        self.recentToReturn = recentToReturn
        self.shouldThrowOnRecent = shouldThrowOnRecent
    }

    func recentTracks(limit: Int) throws -> [SongListItem] {
        if shouldThrowOnRecent {
            struct MockError: Error {}
            throw MockError()
        }
        return Array(recentToReturn.prefix(limit))
    }

    func recordPlayback(_ item: SongListItem, playedAt: Date) throws {
        recordCalls.append((item, playedAt))
    }
}
