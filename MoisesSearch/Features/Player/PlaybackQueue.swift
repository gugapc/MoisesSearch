//
//  PlaybackQueue.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 01/05/26.
//

import Foundation

/// In-memory queue: whatever list the user sees on the home becomes the playback order when they tap a track.
@MainActor
@Observable
final class PlaybackQueue {
    private(set) var tracks: [SongListItem] = []
    private(set) var currentIndex: Int = 0

    var currentTrack: SongListItem? {
        guard tracks.indices.contains(currentIndex) else { return nil }
        return tracks[currentIndex]
    }

    func replace(with items: [SongListItem], startAt index: Int) {
        tracks = items
        guard !tracks.isEmpty else {
            currentIndex = 0
            return
        }
        currentIndex = min(max(0, index), tracks.count - 1)
    }
}
