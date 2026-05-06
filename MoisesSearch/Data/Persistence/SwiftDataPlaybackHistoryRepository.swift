//
//  SwiftDataPlaybackHistoryRepository.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 03/05/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataPlaybackHistoryRepository: PlaybackHistoryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recentTracks(limit: Int) throws -> [SongListItem] {
        var descriptor = FetchDescriptor<PlayedTrackEntity>(
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor).map { $0.toSongListItem() }
    }

    func recordPlayback(_ item: SongListItem, playedAt: Date) throws {
        let id = item.id
        var descriptor = FetchDescriptor<PlayedTrackEntity>(
            predicate: #Predicate { $0.appleTrackId == id }
        )
        descriptor.fetchLimit = 1
        if let existing = try modelContext.fetch(descriptor).first {
            existing.title = item.title
            existing.artist = item.artist
            existing.albumTitle = item.albumTitle
            existing.playedAt = playedAt
            existing.artworkURLString = item.artworkURL?.absoluteString
            existing.previewURLString = item.previewURL?.absoluteString
        } else {
            modelContext.insert(PlayedTrackEntity.from(item, playedAt: playedAt))
        }
        try modelContext.save()
    }
}
