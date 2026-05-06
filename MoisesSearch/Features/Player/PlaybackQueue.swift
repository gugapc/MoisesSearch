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

    var canAdvance: Bool { currentIndex < tracks.count - 1 }
    var canRewind: Bool { currentIndex > 0 }

    func replace(with items: [SongListItem], startAt index: Int) {
        tracks = items
        guard !tracks.isEmpty else {
            currentIndex = 0
            return
        }
        currentIndex = min(max(0, index), tracks.count - 1)
    }
    
    func advanceToNext() {
        guard !tracks.isEmpty else { return }
        if currentIndex < tracks.count - 1 {
            currentIndex += 1
        }
    }

    func skipToPrevious() {
        guard !tracks.isEmpty else { return }
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    func jumpToTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        currentIndex = index
    }
}
