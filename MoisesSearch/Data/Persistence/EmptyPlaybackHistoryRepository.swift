//
//  EmptyPlaybackHistoryRepository.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation

/// No-op persistence (previews, tests without SwiftData).
@MainActor
final class EmptyPlaybackHistoryRepository: PlaybackHistoryRepository {
    func recentTracks(limit: Int) throws -> [SongListItem] {
        _ = limit
        return []
    }

    func recordPlayback(_ item: SongListItem, playedAt: Date) throws {
        _ = item
        _ = playedAt
    }
}
