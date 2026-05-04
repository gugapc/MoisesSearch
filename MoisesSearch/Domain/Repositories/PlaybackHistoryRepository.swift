//
//  PlaybackHistoryRepository.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation

/// Persisted “recently played” for the home empty-query state (offline-first).
@MainActor
protocol PlaybackHistoryRepository: AnyObject {
    /// Most recently played first.
    func recentTracks(limit: Int) throws -> [SongListItem]
    /// Upsert by stable track id (`SongListItem.id`, e.g. Apple `trackId` string).
    func recordPlayback(_ item: SongListItem, playedAt: Date) throws
}
